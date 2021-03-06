require "spec_helper"

RSpec.describe PostgramRaidexes do
  before do
    migrate_test_app
  end

  it "dumps trigram indexes" do
    users_email_index = 'add_index "users", ["email"], name: "index_users_on_email_trigram", using: :gin, opclasses: {"email"=>"gin_trgm_ops"}'
    users_last_name_index = 'add_index "users", ["last_name"], name: "index_users_on_last_name_trigram", using: :gin, opclasses: {"last_name"=>"gin_trgm_ops"}'

    schema_lines = dumped_schema_lines_from_test_app

    expect(schema_lines).to include_line(users_email_index)
    expect(schema_lines).to include_line(users_last_name_index)
  end

  it "doesn't mangle partial indexes" do
    expected_partial_index = 'add_index "users", ["first_name"], name: "index_users_on_first_name", where: "(first_name IS NOT NULL)", using: :btree'

    expect(dumped_schema_lines_from_test_app).to include_line(expected_partial_index)
  end

  def migrate_test_app
    delete_old_schema_file
    setup_test_database
    migrate
  end

  def delete_old_schema_file
    test_schema_path = "spec/support/test_app/db/schema.rb"
    File.delete(test_schema_path) if File.exist?(test_schema_path)
  end

  def setup_test_database
    `cd spec/support/test_app && bundle exec rake db:drop db:create`
  end

  def migrate
    `cd spec/support/test_app && bundle exec rake db:migrate`
  end

  def dumped_schema_lines_from_test_app
    File.readlines("spec/support/test_app/db/schema.rb")
  end

  RSpec::Matchers.define :include_line do |expected_line|
    match do |lines|
      lines.any? do |actual_line|
        actual_line.strip == expected_line
      end
    end
  end
end
