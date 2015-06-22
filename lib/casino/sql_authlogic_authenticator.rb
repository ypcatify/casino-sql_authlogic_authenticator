require 'active_record'
require 'authlogic'

class CASino::SQLAuthLogicAuthenticator

  class AuthDatabase < ::ActiveRecord::Base
    self.abstract_class = true
  end

  def initialize(options)
    set_options options
    validate_options
    model_name = get_model_name
    model_name = classify_table_model_name model_name if model_name == options[:table]
    model_class_name = "#{self.class.to_s}::#{model_name}"
    load_class model_class_name
    @model = model_class_name.constantize
    @model.establish_connection @options[:connection]
  end

  def validate(username, password)
    user = @model.send("find_by_#{@options[:username_column]}!", username)
    crypted_password = user.send(@options[:password_column])
    password_salt = user.send(@options[:password_salt_column])

    if valid_password?(password, crypted_password, password_salt)
      user_data(user)
    else
      false
    end
  rescue ActiveRecord::RecordNotFound
    false
  end

  def load_user_data(username)
    user = @model.send("find_by_#{@options[:username_column]}!", username)
    user_data(user)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def set_options options
    if !options.respond_to?(:deep_symbolize_keys)
      raise ArgumentError, "When assigning attributes, you must pass a hash as an argument."
    end
    @options = options.deep_symbolize_keys
  end

  def validate_options
    raise ArgumentError, "Table name is missing" if @options[:table].blank?
    if @options[:encryptor] && !(allowed_encryptors.include?(@options[:encryptor]))
      raise ArgumentError, "Bad encryptor. Available encryptors: #{allowed_encryptors.join(',')}"
    end
  end

  def allowed_encryptors
    ["Sha512", "AES256", "BCrypt", "MD5", "Sha1"]
  end

  def get_model_name
    @options[:model_name].present? ? @options[:model_name] : @options[:table]
  end

  def classify_table_model_name model_name
    if @options[:connection].kind_of?(Hash) && @options[:connection][:database]
      model_name = "#{@options[:connection][:database].gsub(/[^a-zA-Z]+/, '')}_#{model_name}"
    end
    model_name.classify
  end

  def load_class model_class_name
    eval <<-END
        class #{model_class_name} < AuthDatabase
          self.table_name = "#{@options[:table]}"
          self.inheritance_column = :_type_disabled
        end
      END
  end

  def user_data user
    { username: user.send(@options[:username_column]), extra_attributes: extra_attributes(user) }
  end

  def valid_password? password, crypted_password, password_salt
    return false if crypted_password.blank?
    tokens = [password, password_salt]
    encryptor.matches?(crypted_password, tokens)
  end

  def encryptor
    encryptor = @options[:encryptor] || "Sha512"
    eval("Authlogic::CryptoProviders::#{encryptor}")
  end


  def extra_attributes(user)
    attributes = {}
    extra_attributes_option.each do |attribute_name, database_column|
      attributes[attribute_name] = user.send(database_column)
    end
    attributes
  end

  def extra_attributes_option
    @options[:extra_attributes] || {}
  end
end
