# name: ip-anonymizer
# about: Nullifies IP addresses of users with trustlevel 1+ (admin option)
# version: 0.1
# authors: Overgrow
# url: https://github.com/overgrow/discourse-ip-anonymizer

enabled_site_setting :ip_anonymizer_enabled

after_initialize do
  
  module ::Jobs
    class IpAnonymizer < Jobs::Scheduled
      every 1.hour
  
      sidekiq_options retry: false
  
      def execute(args)
        anonymize_ip if SiteSetting.ip_anonymizer_enabled?
      end
      
      def anonymize_ip
        
        cnn = ActiveRecord::Base.connection.raw_connection
        time_cutoff = Time.zone.now - 1.hour

        User.where("trust_level >= ?", SiteSetting.ip_anonymizer_min_trustlevel)
            .where("last_seen_at <= ?", time_cutoff)
            .find_each do |user|
          begin
            puts user.username
            results = cnn.async_exec("UPDATE users SET ip_address = '', registration_ip_address = '' WHERE id = '#{user.id}'").to_a 
            results = cnn.async_exec("UPDATE topic_views SET ip_address = '' WHERE user_id = '#{user.id}'").to_a 
            results = cnn.async_exec("UPDATE topic_link_clicks SET ip_address = '' WHERE user_id = '#{user.id}'").to_a 
            results = cnn.async_exec("UPDATE user_histories SET ip_address = '' WHERE acting_user_id = '#{user.id}'").to_a 
            results = cnn.async_exec("UPDATE user_profile_views SET ip_address = NULL WHERE user_id = '#{user.id}'").to_a 
            results = cnn.async_exec("UPDATE incoming_links SET ip_address = NULL WHERE user_id = '#{user.id}'").to_a 
            results.each do |result|
          end
        end

      end
    end
  end

end