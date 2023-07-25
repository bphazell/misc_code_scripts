# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140221011015) do

  create_table "public.akon_users", :id => false, :force => true do |t|
    t.string   "id",                         :limit => 65535
    t.string   "name",                       :limit => 65535
    t.string   "email",                      :limit => 65535
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.float    "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",         :limit => 65535
    t.string   "last_sign_in_ip",            :limit => 65535
    t.float    "failed_attempts"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "email_verified_at"
    t.datetime "email_verification_sent_at"
    t.boolean  "disabled"
  end

  create_table "public.all_worker_uuids", :id => false, :force => true do |t|
    t.string "uuid",      :limit => 65535
    t.float  "worker_id"
  end

  create_table "public.auth_central_account_contributors", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "account_id"
    t.float    "contributor_id"
    t.datetime "created_at"
  end

  create_table "public.auth_central_accounts", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "uuid",                     :limit => 65535
    t.string   "name",                     :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                    :limit => 65535
    t.string   "unconfirmed_email",        :limit => 65535
    t.float    "failed_attempts"
    t.string   "unlock_token",             :limit => 65535
    t.string   "locked_at",                :limit => 65535
    t.string   "company",                  :limit => 65535
    t.float    "preferred_contributor_id"
  end

  create_table "public.auth_central_contributors", :id => false, :force => true do |t|
    t.float "id"
    t.float "builder_id"
  end

  create_table "public.builder_assignments", :id => false, :force => true do |t|
    t.string   "id",            :limit => 65535
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "converted_at"
    t.string   "kind",          :limit => 65535
    t.float    "job_id"
    t.boolean  "approved"
    t.float    "api_version"
    t.string   "country",       :limit => 65535
    t.float    "worker_id"
    t.float    "amount"
    t.string   "external_type", :limit => 65535
    t.string   "external_id",   :limit => 65535
    t.string   "judgment_ids",  :limit => 65535
  end

  create_table "public.builder_channels", :id => false, :force => true do |t|
    t.boolean  "public"
    t.boolean  "approved"
    t.string   "name",                      :limit => 65535
    t.string   "label",                     :limit => 65535
    t.string   "summary",                   :limit => 65535
    t.string   "affiliate_id",              :limit => 65535
    t.string   "start_uri",                 :limit => 65535
    t.string   "finish_uri",                :limit => 65535
    t.float    "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bpo"
    t.float    "min_conversion"
    t.float    "max_wait"
    t.float    "conversion_rate"
    t.string   "conversion_name",           :limit => 65535
    t.boolean  "index_verification"
    t.float    "api_version"
    t.boolean  "live"
    t.string   "custom_pixel_url",          :limit => 65535
    t.string   "language",                  :limit => 65535
    t.string   "type",                      :limit => 65535
    t.boolean  "adult"
    t.float    "minimum_hourly_wage"
    t.string   "locations",                 :limit => 65535
    t.float    "scam_tendency"
    t.boolean  "ignores_id_character_case"
    t.datetime "deleted_at"
    t.boolean  "disabled"
    t.boolean  "show_job_listing"
    t.boolean  "has_terms_of_service"
    t.string   "custom_css_url",            :limit => 65535
  end

  create_table "public.builder_conversions", :id => false, :force => true do |t|
    t.string   "_id",             :limit => 65535
    t.boolean  "accurate"
    t.float    "adjusted_amount"
    t.float    "amount"
    t.string   "country",         :limit => 65535
    t.string   "currency",        :limit => 65535
    t.string   "external_id",     :limit => 65535
    t.string   "external_type",   :limit => 65535
    t.datetime "finished_at"
    t.float    "job_id"
    t.float    "judgments"
    t.string   "response",        :limit => 65535
    t.datetime "started_at"
    t.boolean  "tainted"
    t.string   "uid",             :limit => 65535
    t.float    "worker_id"
    t.float    "bonus_amount"
    t.string   "_extra_props",    :limit => 65535
  end

  create_table "public.builder_conversions_old", :id => false, :force => true do |t|
    t.string   "_id",             :limit => 65535
    t.string   "accurate",        :limit => 65535
    t.string   "adjusted_amount", :limit => 65535
    t.float    "amount"
    t.string   "country",         :limit => 65535
    t.string   "currency",        :limit => 65535
    t.string   "external_id",     :limit => 65535
    t.string   "external_type",   :limit => 65535
    t.datetime "finished_at"
    t.float    "job_id"
    t.float    "judgments"
    t.string   "started_at",      :limit => 65535
    t.string   "tainted",         :limit => 65535
    t.string   "uid",             :limit => 65535
    t.float    "worker_id"
    t.string   "bonus_amount",    :limit => 65535
    t.string   "_extra_props",    :limit => 65535
  end

  create_table "public.builder_job_channels", :id => false, :force => true do |t|
    t.float  "job_id"
    t.string "channel_name",  :limit => 65535
    t.string "external_id",   :limit => 65535
    t.float  "payment_cents"
  end

  create_table "public.builder_job_countries", :id => false, :force => true do |t|
    t.string  "country_code", :limit => 65535
    t.float   "job_id"
    t.boolean "excluded"
  end

  create_table "public.builder_jobs", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "variables",                             :limit => 65535
    t.string   "instructions",                          :limit => 65535
    t.string   "problem",                               :limit => 65535
    t.datetime "created_at"
    t.float    "user_id"
    t.string   "title",                                 :limit => 65535
    t.float    "judgments_per_unit"
    t.float    "units_per_assignment"
    t.string   "external_id",                           :limit => 65535
    t.string   "external_type",                         :limit => 65535
    t.float    "payment_cents"
    t.float    "gold_per_assignment"
    t.string   "cml_fields",                            :limit => 65535
    t.datetime "locked_at"
    t.string   "bad_gold_at",                           :limit => 65535
    t.float    "calibrated_unit_time"
    t.string   "include_tainted",                       :limit => 65535
    t.string   "low_needed_tasks_reservation_takeover", :limit => 65535
    t.string   "direct_reservation",                    :limit => 65535
    t.string   "ignore_gold",                           :limit => 65535
    t.string   "include_unfinished",                    :limit => 65535
    t.string   "flag_on_rate_limit",                    :limit => 65535
    t.float    "warn_at"
    t.string   "front_load",                            :limit => 65535
    t.string   "null_confidence",                       :limit => 65535
    t.string   "mail_to",                               :limit => 65535
    t.string   "approved",                              :limit => 65535
    t.float    "after_gold"
    t.string   "hide_correct_answers",                  :limit => 65535
    t.string   "confidence_fields",                     :limit => 65535
    t.string   "ignore_difficulty",                     :limit => 65535
    t.string   "htl_report",                            :limit => 65535
    t.string   "keywords",                              :limit => 65535
    t.string   "override_gold",                         :limit => 65535
    t.float    "reject_at"
    t.string   "qualificationrequirement",              :limit => 65535
    t.float    "pages_per_assignment"
    t.datetime "updated_at"
    t.datetime "notification_sent_at"
    t.string   "custom_key",                            :limit => 65535
    t.datetime "completed_at"
    t.datetime "stats_run_at"
    t.string   "webhook_uri",                           :limit => 65535
    t.boolean  "auto_order"
    t.float    "num_assignments"
    t.boolean  "starred"
    t.string   "language",                              :limit => 65535
    t.float    "max_judgments_per_worker"
    t.string   "deleted_at_date",                       :limit => 65535
    t.string   "iterating_on",                          :limit => 65535
    t.float    "cml_definition_id"
    t.boolean  "survey"
    t.float    "state"
    t.float    "max_judgments_per_unit"
    t.float    "min_unit_confidence"
    t.float    "max_assignments_per_minute"
    t.boolean  "schedule_fifo"
    t.boolean  "send_judgments_webhook"
    t.float    "auto_order_timeout"
    t.float    "gold_mode"
    t.float    "auto_order_threshold"
    t.boolean  "high_jpu"
    t.float    "max_unit_confidence"
    t.float    "variable_judgments_mode"
    t.boolean  "units_remain_finalized"
    t.string   "alias",                                 :limit => 65535
    t.float    "max_judgments_per_ip"
    t.string   "project_number",                        :limit => 65535
    t.string   "minimum_requirements",                  :limit => 65535
    t.string   "desired_requirements",                  :limit => 65535
    t.float    "expected_judgments_per_unit"
    t.boolean  "is_nuggeted"
    t.float    "execution_mode"
    t.boolean  "design_verified"
    t.float    "minimum_account_age_seconds"
    t.boolean  "require_worker_login"
    t.boolean  "order_approved"
    t.boolean  "public_data"
    t.float    "min_assignment_duration"
    t.boolean  "flag_on_min_assignment_duration"
    t.boolean  "send_emails_on_rate_limit"
  end

  create_table "public.builder_judgment_data", :id => false, :force => true do |t|
    t.float  "judgment_id"
    t.string "data",        :limit => 65535
    t.string "logic",       :limit => 65535
  end

  create_table "public.builder_judgments", :id => false, :force => true do |t|
    t.float    "id"
    t.datetime "created_at"
    t.string   "external_id",     :limit => 65535
    t.string   "external_type",   :limit => 65535
    t.float    "judgment"
    t.float    "trust"
    t.float    "worker_id"
    t.float    "unit_id"
    t.float    "job_id"
    t.datetime "started_at"
    t.boolean  "rejected"
    t.boolean  "missed"
    t.boolean  "contested"
    t.boolean  "tainted"
    t.string   "ip",              :limit => 65535
    t.float    "workset_id"
    t.string   "country",         :limit => 65535
    t.string   "region",          :limit => 65535
    t.string   "city",            :limit => 65535
    t.boolean  "reviewed"
    t.float    "original_id"
    t.boolean  "golden"
    t.datetime "webhook_sent_at"
    t.datetime "updated_at"
  end

  create_table "public.builder_orders", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "amount_in_cents"
    t.string   "transaction_id",       :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "job_id"
    t.float    "user_id"
    t.float    "kind"
    t.string   "meta",                 :limit => 65535
    t.string   "type",                 :limit => 65535
    t.float    "debit_id"
    t.float    "percentage"
    t.float    "nuggeted_units_count"
    t.boolean  "confirmed"
    t.string   "description",          :limit => 65535
    t.float    "value_in_cents"
    t.string   "payment_plan",         :limit => 65535
  end

  create_table "public.builder_units", :id => false, :force => true do |t|
    t.float    "id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data",                          :limit => 65535
    t.float    "judgments_count"
    t.float    "state"
    t.float    "job_id"
    t.string   "golden",                        :limit => 65535
    t.float    "difficulty"
    t.float    "grouping"
    t.string   "custom_key",                    :limit => 65535
    t.float    "agreement"
    t.datetime "lazy_stats_at"
    t.float    "missed_count"
    t.float    "number_of_accurate_judgments"
    t.string   "stats",                         :limit => 65535
    t.string   "author_id",                     :limit => 65535
    t.float    "cml_definition_id"
    t.float    "original_id"
    t.float    "number_of_requested_judgments"
    t.string   "webhook_sent",                  :limit => 65535
    t.float    "contested_count"
    t.string   "gold_stream_names",             :limit => 65535
    t.string   "copy_source_unit",              :limit => 65535
    t.string   "gold_case",                     :limit => 65535
    t.string   "canary",                        :limit => 65535
    t.string   "review_state",                  :limit => 65535
    t.datetime "edited_at"
  end

  create_table "public.builder_users", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "email",             :limit => 65535
    t.boolean  "admin"
    t.boolean  "active"
    t.float    "credits"
    t.datetime "created_at"
    t.datetime "auth_expiration"
    t.string   "first_name",        :limit => 65535
    t.string   "last_name",         :limit => 65535
    t.string   "auth_key",          :limit => 65535
    t.string   "company",           :limit => 65535
    t.string   "affiliate_channel", :limit => 65535
    t.string   "affiliate_id",      :limit => 65535
    t.datetime "last_logged_in_at"
    t.float    "role"
    t.string   "external_type",     :limit => 65535
    t.boolean  "diy"
    t.float    "contact_status"
    t.string   "processor_role",    :limit => 65535
    t.float    "company_type"
    t.float    "job_type"
    t.string   "phone_number",      :limit => 65535
    t.string   "cf_support_email",  :limit => 65535
    t.boolean  "license"
    t.boolean  "order_approved"
    t.string   "akon_id",           :limit => 65535
    t.string   "project_number",    :limit => 65535
  end

  create_table "public.builder_worker_notes", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "owning_model", :limit => 65535
    t.string   "owning_id",    :limit => 65535
    t.float    "user_id"
    t.string   "note",         :limit => 65535
    t.datetime "created_at"
    t.float    "type"
    t.float    "job_id"
  end

  create_table "public.builder_workers", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "external_id",     :limit => 65535
    t.string   "external_type",   :limit => 65535
    t.float    "judgments_count"
    t.float    "trust"
    t.float    "gold_acc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "meta",            :limit => 65535
    t.string   "sex",             :limit => 65535
    t.float    "age"
    t.string   "education",       :limit => 65535
    t.string   "ethnicity",       :limit => 65535
    t.string   "zip_code",        :limit => 65535
    t.datetime "banned_at"
    t.string   "email",           :limit => 65535
    t.float    "feedback_count"
    t.string   "extra_params",    :limit => 65535
    t.string   "user_id",         :limit => 65535
  end

  create_table "public.builder_worksets", :id => false, :force => true do |t|
    t.float    "job_id"
    t.float    "worker_id"
    t.float    "golden_trust"
    t.float    "agreement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "judgments_count"
    t.float    "missed_count"
    t.float    "golds_count"
    t.float    "id"
    t.datetime "flagged_at"
    t.string   "flag_reason",                          :limit => 65535
    t.datetime "rejected_at"
    t.float    "bonus"
    t.datetime "approved_at"
    t.float    "workpool_id"
    t.float    "forgiven_count"
    t.float    "feedback_count"
    t.boolean  "front_loading"
    t.float    "frontload_count"
    t.float    "frontload_missed"
    t.float    "work_phase"
    t.boolean  "tainted"
    t.float    "converted_amount"
    t.datetime "distribution_violation_email_sent_at"
  end

  create_table "public.churn_monthly", :id => false, :force => true do |t|
    t.datetime "week_date"
    t.float    "level"
    t.float    "num_workers"
    t.float    "num_returning"
    t.float    "percent_returning"
    t.string   "group",             :limit => 65535
    t.datetime "updated_at_date"
  end

  create_table "public.churn_weekly", :id => false, :force => true do |t|
    t.datetime "week_date"
    t.float    "level"
    t.float    "num_workers"
    t.string   "num_returning",     :limit => 65535
    t.string   "percent_returning", :limit => 65535
    t.string   "group",             :limit => 65535
    t.datetime "updated_at_date"
  end

  create_table "public.data147_builder_stats", :id => false, :force => true do |t|
    t.string  "uuid",                      :limit => 65535
    t.float   "turk_worker_id"
    t.string  "amt_worker_id",             :limit => 65535
    t.integer "jobs_count",                :limit => 8
    t.integer "projects_count",            :limit => 8
    t.float   "total_judgments"
    t.integer "kinda_total_flags",         :limit => 8
    t.float   "total_tainted_judgments"
    t.float   "total_untainted_judgments"
  end

  create_table "public.data147_first_channel_identities", :id => false, :force => true do |t|
    t.string  "uuid",                       :limit => 65535
    t.string  "external_type",              :limit => 65535
    t.float   "first_id"
    t.integer "num_contributor_identities", :limit => 8
  end

  create_table "public.data147_lifetime_contributor_earnings", :id => false, :force => true do |t|
    t.string "channel_name",     :limit => 65535
    t.float  "worker_id"
    t.float  "total_conversion"
  end

  create_table "public.data147_lifetime_real_contributor_earnings", :id => false, :force => true do |t|
    t.string "channel_name",     :limit => 65535
    t.string "uuid",             :limit => 65535
    t.float  "total_conversion"
  end

  create_table "public.data147_turk_only_users", :id => false, :force => true do |t|
    t.string  "uuid",                     :limit => 65535
    t.integer "turk_ids",                 :limit => 8
    t.float   "turk_payout"
    t.float   "turk_judgments_count"
    t.integer "turk_banned_at"
    t.integer "non_turk_ids",             :limit => 8
    t.float   "non_turk_payout"
    t.float   "non_turk_judgments_count"
    t.integer "non_turk_banned_at"
  end

  create_table "public.data160_builder_per_job_overcollection", :id => false, :force => true do |t|
    t.datetime "work_hour"
    t.float    "overcollection_judgment_count"
    t.float    "overcollection_cost_cents"
    t.float    "overcollection_affected_jobs"
  end

  create_table "public.data160_builder_per_job_overcollection_take2", :id => false, :force => true do |t|
    t.datetime "work_hour"
    t.float    "overcollection_judgment_count"
    t.float    "overcollection_cost_cents"
    t.float    "overcollection_affected_jobs"
  end

  create_table "public.data160_overcollection_by_hour", :id => false, :force => true do |t|
    t.datetime "work_hour"
    t.integer  "overcollection_judgment_count", :limit => 8
    t.float    "overcollection_cost_cents"
    t.integer  "overcollection_affected_jobs",  :limit => 8
  end

  create_table "public.data160_overcollection_by_job_by_week", :id => false, :force => true do |t|
    t.float    "job_id"
    t.datetime "work_week"
    t.integer  "overcollection_judgment_count", :limit => 8
    t.float    "overcollection_cost_cents"
    t.integer  "overcollection_affected_jobs",  :limit => 8
  end

  create_table "public.data_149_amt_conversions", :id => false, :force => true do |t|
    t.string "recipient_id",            :limit => 65535
    t.float  "amt_amount_without_fees"
    t.float  "amt_amount_with_fees"
  end

  create_table "public.data_149_amt_workers_sept_to_dec", :id => false, :force => true do |t|
    t.float  "id"
    t.string "external_id", :limit => 65535
  end

  create_table "public.data_149_builder_amt_conversions", :id => false, :force => true do |t|
    t.float "worker_id"
    t.float "builder_amount"
    t.float "job_id"
  end

  create_table "public.goldfinger_contentions", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "gold_judgment_id"
    t.string   "reason",           :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "job_id"
    t.float    "upvotes_count"
    t.float    "unit_id"
  end

  create_table "public.goldfinger_evaluations", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "job_source",         :limit => 65535
    t.string   "worker_mode",        :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "accuracy"
    t.boolean  "accuracy_available"
    t.float    "points"
    t.float    "max_points"
    t.string   "workset_id",         :limit => 65535
  end

  create_table "public.goldfinger_gold_judgments", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "evaluation_id"
    t.string   "worker_id",        :limit => 65535
    t.float    "unit_id"
    t.string   "judgment_id",      :limit => 65535
    t.float    "gold_points"
    t.float    "max_gold_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "gold_instance_id"
    t.string   "state",            :limit => 65535
    t.datetime "forgiven_at"
    t.string   "data",             :limit => 65535
    t.string   "missed_fields",    :limit => 65535
    t.string   "missed_nuggets",   :limit => 65535
    t.float    "job_id"
    t.string   "worker_mode",      :limit => 65535
  end

  create_table "public.judgments_judgment_data", :id => false, :force => true do |t|
    t.string  "judgment_id",        :limit => 65535
    t.string  "field",              :limit => 65535
    t.string  "value",              :limit => 65535
    t.boolean "hidden"
    t.string  "field_with_indices", :limit => 65535
  end

  create_table "public.judgments_judgments", :id => false, :force => true do |t|
    t.string   "id",           :limit => 65535
    t.float    "job_id"
    t.float    "unit_id"
    t.float    "worker_id"
    t.float    "workset_id"
    t.string   "work_mode",    :limit => 65535
    t.string   "user_uuid",    :limit => 65535
    t.string   "channel_id",   :limit => 65535
    t.string   "ip",           :limit => 65535
    t.string   "country",      :limit => 65535
    t.string   "region",       :limit => 65535
    t.string   "city",         :limit => 65535
    t.datetime "created_at"
    t.datetime "started_at"
    t.datetime "submitted_at"
  end

  create_table "public.latest_workers", :id => false, :force => true do |t|
    t.float    "worker_id"
    t.datetime "max_created_at"
  end

  create_table "public.monthly_contributor_earnings", :id => false, :force => true do |t|
    t.string   "channel_name",     :limit => 65535
    t.float    "worker_id"
    t.datetime "conversion_month"
    t.float    "total_conversion"
  end

  create_table "public.profiles_contributors", :id => false, :force => true do |t|
    t.float    "id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "builder_contributor_id"
    t.string   "auth_central_account_uuid", :limit => 65535
  end

  create_table "public.profiles_profile_elements", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "skill_id"
    t.float    "contributor_id"
    t.float    "numeric_value"
    t.string   "string_value",   :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.profiles_profile_elements_tmp", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "skill_id"
    t.float    "contributor_id"
    t.float    "numeric_value"
    t.string   "string_value",   :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.profiles_skills", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "name",         :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag_type",     :limit => 65535
    t.string   "display_name", :limit => 65535
    t.string   "description",  :limit => 65535
  end

  create_table "public.schema_migrations", :id => false, :force => true do |t|
    t.string "version", :null => false
  end

  create_table "public.temp_high_earners", :id => false, :force => true do |t|
    t.float "worker_id"
  end

  create_table "public.temp_staging", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",            :limit => 65535
    t.datetime "created_at_date"
    t.datetime "updated_at_date"
  end

  create_table "public.temp_staging_int", :id => false, :force => true do |t|
    t.integer  "id",              :limit => 8
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",            :limit => 65535
    t.datetime "created_at_date"
    t.datetime "updated_at_date"
  end

  create_table "public.work_available_tracking", :id => false, :force => true do |t|
    t.datetime "measured_at"
    t.float    "dollars_available"
    t.string   "requirements",      :limit => 65535
  end

  create_table "public.work_available_tracking_old", :id => false, :force => true do |t|
    t.datetime "measured_at"
    t.float    "dollars_available"
    t.string   "requirements",      :limit => 256
  end

  create_table "public.work_history_summary", :id => false, :force => true do |t|
    t.float    "worker_id"
    t.float    "last_job_id"
    t.float    "judgments_count"
    t.datetime "max_created_at"
    t.integer  "kinda_total_flags", :limit => 8
  end

  create_table "public.worker_ui_assignments", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "uuid",                      :limit => 65535
    t.string   "auth_central_account_uuid", :limit => 65535
    t.float    "builder_worker_id"
    t.float    "job_id"
    t.string   "unit_ids",                  :limit => 65535
    t.string   "state",                     :limit => 65535
    t.string   "worker_mode",               :limit => 65535
    t.datetime "abandoned_at"
    t.datetime "quit_at"
    t.datetime "expires_at"
    t.datetime "expired_at"
    t.datetime "finished_at"
    t.boolean  "approved"
    t.string   "judgment_ids",              :limit => 65535
    t.string   "channel_id",                :limit => 65535
    t.string   "channel_worker_id",         :limit => 65535
    t.string   "conversion_id",             :limit => 65535
    t.float    "units_per_page"
    t.float    "api_version"
    t.string   "country",                   :limit => 65535
    t.string   "missed_gold",               :limit => 65535
    t.string   "amt_assignment_id",         :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "workset_id"
    t.string   "gold_unit_ids",             :limit => 65535
    t.float    "conversion_rate_old"
    t.string   "conversion_name",           :limit => 65535
    t.float    "starting_points"
    t.float    "starting_max_points"
    t.float    "conversion_rate"
    t.string   "ip",                        :limit => 65535
  end

  create_table "public.worker_ui_browser_details", :id => false, :force => true do |t|
    t.float   "id"
    t.string  "md5",                :limit => 65535
    t.string  "user_agent",         :limit => 65535
    t.float   "screen_width"
    t.float   "screen_height"
    t.float   "screen_color_depth"
    t.float   "timezone"
    t.boolean "session_storage"
    t.boolean "local_storage"
    t.string  "plugins",            :limit => 65535
  end

  create_table "public.worker_ui_exit_surveys", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "workset_id"
    t.float    "instructions_clear"
    t.float    "payrate_relativity"
    t.float    "questions_fair"
    t.float    "satisfaction_overall"
    t.float    "task_difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_ip_bans", :id => false, :force => true do |t|
    t.string   "ip",         :limit => 65535
    t.string   "banned_by",  :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_ip_stats", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "ip",                   :limit => 65535
    t.float    "job_id"
    t.float    "judgments_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "max_work_restriction"
  end

  create_table "public.worker_ui_notifications", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "type",       :limit => 65535
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "state",      :limit => 65535
    t.string   "message",    :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_rate_limits", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "job_id"
    t.float    "worker_id"
    t.string   "ip",               :limit => 65535
    t.float    "velocity"
    t.float    "limit"
    t.string   "violation",        :limit => 65535
    t.float    "violations_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_request_details", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "ip",                               :limit => 65535
    t.string   "country",                          :limit => 65535
    t.string   "region",                           :limit => 65535
    t.string   "city",                             :limit => 65535
    t.string   "referer",                          :limit => 65535
    t.string   "primary_accepted_language_locale", :limit => 65535
    t.string   "primary_language",                 :limit => 65535
    t.string   "secondary_accepted_languages",     :limit => 65535
    t.float    "prev_worker_id"
    t.float    "browser_details_id"
    t.string   "kind",                             :limit => 65535
    t.datetime "created_at"
  end

  create_table "public.worker_ui_vanity_participants", :id => false, :force => true do |t|
    t.float    "id"
    t.string   "experiment_id", :limit => 65535
    t.float    "identity"
    t.float    "shown"
    t.float    "seen"
    t.float    "converted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_worker_clone_groups", :id => false, :force => true do |t|
    t.float "worker_id"
    t.float "group_id"
  end

  create_table "public.worker_ui_worker_clones", :id => false, :force => true do |t|
    t.float    "curr_worker_id"
    t.float    "prev_worker_id"
    t.float    "job_id"
    t.string   "ip",             :limit => 65535
    t.string   "country",        :limit => 65535
    t.datetime "created_at"
  end

  create_table "public.worker_ui_worker_notes", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",       :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_worker_notes_perf", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",            :limit => 65535
    t.datetime "created_at_date"
    t.datetime "updated_at_date"
  end

  create_table "public.worker_ui_worker_notes_perf_2", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",            :limit => 65535
    t.datetime "created_at_date"
    t.datetime "updated_at_date"
  end

  create_table "public.worker_ui_worker_notes_perf_int", :id => false, :force => true do |t|
    t.integer  "id",              :limit => 8
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",            :limit => 65535
    t.datetime "created_at_date"
    t.datetime "updated_at_date"
  end

  create_table "public.worker_ui_worker_notes_perf_joined", :id => false, :force => true do |t|
    t.integer  "id",              :limit => 8
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",            :limit => 65535
    t.datetime "created_at_date"
    t.datetime "updated_at_date"
  end

  create_table "public.worker_ui_worker_notes_test", :id => false, :force => true do |t|
    t.float    "id"
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",       :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_worker_notes_test2", :id => false, :force => true do |t|
    t.float    "id",                          :null => false
    t.float    "worker_id"
    t.float    "job_id"
    t.string   "note",       :limit => 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public.worker_ui_worksets", :id => false, :force => true do |t|
    t.float  "id"
    t.string "job_id",               :limit => 65535
    t.float  "builder_worker_id"
    t.float  "judgments_count"
    t.string "created_at",           :limit => 65535
    t.string "updated_at",           :limit => 65535
    t.string "max_work_restriction", :limit => 65535
    t.string "flagged_restriction",  :limit => 65535
    t.float  "evaluation_id"
  end

  create_table "public.worker_uuids_from_auth_central", :id => false, :force => true do |t|
    t.string "uuid",       :limit => 65535
    t.float  "builder_id"
  end

  create_table "public.worker_uuids_from_notes", :id => false, :force => true do |t|
    t.float   "worker_id"
    t.string  "uuid",        :limit => 144
    t.integer "total_notes", :limit => 8
  end

  create_table "public.ybq5q8lk", :id => false, :force => true do |t|
    t.string   "mongo_id",                :limit => 65535
    t.boolean  "accurate"
    t.float    "adjusted_amount"
    t.float    "amount"
    t.string   "country",                 :limit => 65535
    t.string   "currency",                :limit => 65535
    t.string   "channel_conversion_id",   :limit => 65535
    t.string   "channel_name",            :limit => 65535
    t.datetime "finished_at"
    t.float    "job_id"
    t.float    "judgments"
    t.string   "response",                :limit => 65535
    t.datetime "started_at"
    t.boolean  "tainted"
    t.string   "channel_contributor_uid", :limit => 65535
    t.float    "builder_contributor_id"
    t.float    "bonus_amount"
    t.string   "_extra_props",            :limit => 65535
  end

  create_table "public.zeroscam_joins", :id => false, :force => true do |t|
    t.integer "worker_id"
    t.integer "job_id"
  end

end
