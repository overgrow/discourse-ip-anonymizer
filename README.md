# discourse-ip-anonymizer
Nullifies IP addresses of users with trustlevel X+ (set by admin option)

aka No Data Retention Policy

Sidekiq job that runs hourly and removes IP addresses from all respective database tables.
This affects only registered users with at least trustlevel X (selectable in admin panel, default = 1).
