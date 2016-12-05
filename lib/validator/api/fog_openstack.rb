module Validator
  module Api
    class FogOpenStack
      class << self

        def compute
          Fog::Compute::OpenStack.new(convert_to_fog_params(openstack_params))
        rescue Excon::Errors::SocketError => e
          raise_wrapped_socket_error(openstack_params['auth_url'], e)
        end

        def network
          Fog::Network::OpenStack.new(convert_to_fog_params(openstack_params))
        rescue Excon::Errors::SocketError => e
          raise_wrapped_socket_error(openstack_params['auth_url'], e)
        end

        def image
          Fog::Image::OpenStack::V2.new(convert_to_fog_params(openstack_params))
        rescue Fog::OpenStack::Errors::ServiceUnavailable
          Fog::Image::OpenStack::V1.new(convert_to_fog_params(openstack_params))
        rescue Excon::Errors::SocketError => e
          raise_wrapped_socket_error(openstack_params['auth_url'], e)
        end

        def volume
          Fog::Volume::OpenStack::V2.new(convert_to_fog_params(openstack_params))
        rescue Fog::OpenStack::Errors::ServiceUnavailable
          Fog::Volume::OpenStack::V1.new(convert_to_fog_params(openstack_params))
        rescue Excon::Errors::SocketError => e
          raise_wrapped_socket_error(openstack_params['auth_url'], e)
        end

        private

        def raise_wrapped_socket_error(auth_url, e)
          raise ValidatorError, "Could not connect to '#{auth_url}'", e.backtrace
        end

        def openstack_params
          Api.configuration.openstack
        end

        def convert_to_fog_params(options)
          {
              :openstack_auth_url => options['auth_url'],
              :openstack_username => options['username'],
              :openstack_api_key => options['api_key'],
              :openstack_tenant => options['tenant'],
              :openstack_project_name => options['project'],
              :openstack_domain_name => options['domain'],
              :openstack_region => options['region'],
              :openstack_endpoint_type => options['endpoint_type'] || 'publicURL',
              :connection_options => options['connection_options']
          }
        end
      end
    end
  end
end
