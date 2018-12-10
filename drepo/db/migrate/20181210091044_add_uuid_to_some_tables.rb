# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddUuidToSomeTables < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  # When using the methods "add_concurrent_index", "remove_concurrent_index" or
  # "add_column_with_default" you must disable the use of transactions
  # as these methods can not run in an existing transaction.
  # When using "add_concurrent_index" or "remove_concurrent_index" methods make sure
  # that either of them is the _only_ method called in the migration,
  # any other changes should go in a separate migration.
  # This ensures that upon failure _only_ the index creation or removing fails
  # and can be retried or reverted easily.
  #
  # To disable transactions uncomment the following line and remove these
  # comments:
  disable_ddl_transaction!

  ## Postgres only, because used Postgres builtin function uuid_generate_v4()
  def up
    uuid_tables.each do |table|
      add_column_with_default(table, drepo_column, :uuid, default: "uuid_generate_v4()", allow_null: false) do |t, update_arel|
        update_arel.set([[t[drepo_column], Arel.sql('uuid_generate_v4()')]]) if Arel::UpdateManager === update_arel
        update_arel
      end
      add_concurrent_index table, drepo_column, unique: true
    end
  end

  def down
    uuid_tables.each do |table|
      remove_concurrent_index(table, drepo_column) if index_exists?(table, drepo_column, unique: true)
      remove_column(table, drepo_column) if column_exists?(table, drepo_column)
    end
  end

  def drepo_column
    :drepo_uuid
  end

  def uuid_tables
    [
        # root: User
        'users',

        # root: Project
        'projects',

        # root: Namespace
        'namespaces'
    ]
  end
end
