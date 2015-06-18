require 'spec_helper'
require 'casino/activerecord_authlogic_authenticator'

describe CASino::ActiveRecordAuthLogicAuthenticator do

  let(:pepper) { nil }
  let(:extra_attributes) {{ external_id: 'external_id' }}
  let(:options) do
    {
      connection: {
        adapter: 'sqlite3',
        database: '/tmp/casino-test-auth.sqlite'
      },
      table: 'users',
      username_column: 'email',
      password_column: 'password',
      password_salt_column: 'password_salt',
      pepper: pepper,
      extra_attributes: extra_attributes
    }
  end
  let(:faulty_options){ options.merge(table: nil) }
  let(:connection_as_string) { options.merge(connection: 'sqlite3:/tmp/casino-test-auth.sqlite') }
  let(:user_class) { described_class::TmpcasinotestauthsqliteUser }

  subject { described_class.new(options) }

  before do
    subject # ensure everything is initialized

    ::ActiveRecord::Base.establish_connection options[:connection]

    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define do
        create_table :users do |t|
          t.string :email
          t.string :password
          t.string :password_salt
          t.string :external_id
        end
      end
    end

    user_class.create!(
      email: 'test@exmaple.com',
      password: '019d9f912141c4f43d1627de8944280ef1a88a911fafde3035ddd3a86d4a09d61a8661e1bba49ecfb06bc75f05890b3dd352286530b1b01738a41c72ca15f168', # password: testpassword
      password_salt: 'neE7cKflxj0nwtytMdR',
      external_id: '12345')
  end

  after do
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define do
        drop_table :users
      end
    end
  end

  describe 'custom model name' do
    let(:model_name) { 'DongerRaiser' }
    before do
      options[:model_name] = model_name
    end

    it 'should create the model with the name specified' do
      described_class.new(options)
      expect(described_class.const_get(model_name)).to be_a Class
    end
  end

  describe 'invalid yaml input' do
    context 'no hash input' do
      it 'throws an argument error if the supplied input was not hash' do
        expect{described_class.new("string")}.to raise_error ArgumentError
      end
      it 'does not throw an error if the correct hash was supplied' do
        expect{described_class.new(options)}.not_to raise_error
      end
    end
    context 'invalid table name' do
      it 'throws an argument error if the table was nil/not supplied' do
        expect{described_class.new(faulty_options)}.to raise_error ArgumentError
      end
    end
  end

  describe '#load_user_data' do
    context 'valid username' do
      it 'returns the username' do
        subject.load_user_data('test@exmaple.com')[:username].should eq('test@exmaple.com')
      end

      it 'returns the extra attributes' do
        subject.load_user_data('test@exmaple.com')[:extra_attributes][:external_id].should eq('12345')
      end
    end

    context 'invalid username' do
      it 'returns nil' do
        subject.load_user_data('does-not-exist').should eq(nil)
      end
    end
  end

  describe '#validate' do

    context 'valid username' do
      context 'valid password' do
        it 'returns the username' do
          subject.validate('test@exmaple.com', '123qwe')[:username].should eq('test@exmaple.com')
        end

        it 'returns the extra attributes' do
          subject.validate('test@exmaple.com', '123qwe')[:extra_attributes][:external_id].should eq('12345')
        end

        context 'when no extra attributes given' do
          let(:extra_attributes) { nil }

          it 'returns an empty hash for extra attributes' do
            subject.validate('test@exmaple.com', '123qwe')[:extra_attributes].should eq({})
          end
        end
      end

      context 'invalid password' do
        it 'returns false' do
          subject.validate('test@exmaple.com', 'wrongpassword').should eq(false)
        end
      end

      context 'NULL password field' do
        it 'returns false' do
          user = user_class.first
          user.password = nil
          user.save!

          subject.validate('test@exmaple.com', 'wrongpassword').should eq(false)
        end
      end

      context 'empty password field' do
        it 'returns false' do
          user = user_class.first
          user.password = ''
          user.save!

          subject.validate('test@exmaple.com', 'wrongpassword').should eq(false)
        end
      end
    end

    context 'invalid username' do
      it 'returns false' do
        subject.validate('does-not-exist', 'testpassword').should eq(false)
      end
    end

    context 'support for bcrypt' do
      before do
        user_class.create!(
          username: 'test2',
          password: '$2a$10$dRFLSkYedQ05sqMs3b265e0nnJSoa9RhbpKXU79FDPVeuS1qBG7Jq', # password: testpassword2
          mail_address: 'mail@example.org')
      end

      it 'is able to handle bcrypt password hashes' do
        subject.validate('test2', 'testpassword2').should be_instance_of(Hash)
      end
    end

    context 'support for bcrypt with pepper' do
      let(:pepper) { 'abcdefg' }

      before do
        user_class.create!(
          username: 'test3',
          password: '$2a$10$ndCGPWg5JFMQH/Kl6xKe.OGNaiG7CFIAVsgAOJU75Q6g5/FpY5eX6', # password: testpassword3, pepper: abcdefg
          mail_address: 'mail@example.org')
      end

      it 'is able to handle bcrypt password hashes' do
        subject.validate('test3', 'testpassword3').should be_instance_of(Hash)
      end
    end

    context 'support for phpass' do
      before do
        user_class.create!(
          username: 'test4',
          password: '$P$9IQRaTwmfeRo7ud9Fh4E2PdI0S3r.L0', # password: test12345
          mail_address: 'mail@example.org')
      end

      it 'is able to handle phpass password hashes' do
        subject.validate('test4', 'test12345').should be_instance_of(Hash)
      end
    end

    context 'support for connection string' do

      it 'should not raise an error' do
        expect{described_class.new(connection_as_string)}.to_not raise_error
      end

      it 'returns the username' do
        described_class.new(connection_as_string).load_user_data('test')[:username].should eq('test')
      end
    end

  end

end
