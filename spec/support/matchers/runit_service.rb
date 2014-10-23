def enable_runit_service(service)
  ChefSpec::Matchers::ResourceMatcher.new(:runit_service, :enable, service)
end
