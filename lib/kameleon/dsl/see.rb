module Kameleon
  module Dsl
    module See
      def see(*content)
        options = extract_options(content)

        case options.class.name
          when 'String'
            session.should rspec_world.have_content(options)
          when 'Array'
            options.each do |content_part|
              see(content_part)
            end
          when 'Hash'
            options.each_pair do |value, locator|
              case value.class.name
                when 'Symbol'
                  case value
                    when :button, :buttons
                      one_or_all(locator).each do |selector|
                        session.should rspec_world.have_button(selector)
                      end
                    when :checked, :unchecked
                      one_or_all(locator).each do |selector|
                        session.should rspec_world.send("have_#{value.to_s}_field", selector)
                      end
                    when :disabled, :readonly
                      one_or_all(locator).each do |selector|
                        if selector.respond_to?(:each_pair)
                          selector.each_pair do |text, locator|
                            see text => locator
                            session.find_field(locator)[value].should == ''
                          end
                        else
                          see :field => selector
                          session.find_field(selector)[value].should == ''
                        end
                      end
                    when :empty
                      one_or_all(locator).each do |selector|
                        see :field => selector
                        session.find_field(selector).value.to_s.should == ''
                      end
                    when :error_message_for, :error_messages_for
                      one_or_all(locator).each do |selector|
                        session.find(:xpath, '//div[@id="error_explanation"]').should rspec_world.have_content(selector.capitalize)
                      end
                    when :field, :fields
                      one_or_all(locator).each do |selector|
                        session.should rspec_world.have_field(selector)
                      end
                    when :image, :images
                      one_or_all(locator).each do |selector|
                        session.should rspec_world.have_xpath("//img[@alt=\"#{selector}\"] | //img[@src=\"#{selector}\"]")
                      end
                    when :selected
                      locator.each_pair do |selected_value, selected_locator|
                        session.should rspec_world.have_select(selected_locator, :selected => selected_value)
                      end
                    when :unselected
                      locator.each_pair do |selected_value, selected_locator|
                        session.should rspec_world.have_no_select(selected_locator, :selected => selected_value)
                      end
                    when :link, :links
                      if locator.respond_to?(:each_pair)
                        locator.each_pair do |link_text, url|
                          session.should rspec_world.have_link(link_text, :href => url)
                        end
                      else
                        one_or_all(locator).each { |text| session.should rspec_world.have_link(text) }
                      end
                    when :ordered
                      nodes = session.all(:xpath, locator.collect { |n| "//node()[text()= \"#{n}\"]" }.join(' | '))
                      nodes.map(&:text).should == locator
                    else
                      raise("User can not see #{value} - you need to teach him how")
                  end
                when 'Fixnum'
                  session.should ::Capybara::RSpecMatchers::HaveMatcher.new(*get_selector(locator), :count => value)
                else
                  session.should rspec_world.have_field(locator, :with => value)
              end
            end
          else
            raise "Not Implemented Structure #{options} :: #{options.class}"
        end
      end

      def not_see(*content)
        options = extract_options(content)

        case options.class.name
          when 'String'
            session.should_not rspec_world.have_content(options)
          when 'Array'
            options.each do |content_part|
              session.should_not rspec_world.have_content(content_part)
            end
          when 'Hash'
            options.each_pair do |value, locators|
              case value
                when :button, :buttons
                  one_or_all(locators).each do |selector|
                    session.should_not rspec_world.have_button(selector)
                  end
                when :error_message_for, :error_messages_for
                  one_or_all(locators).each do |selector|
                    session.find(:xpath, '//div[@id="error_explanation"]').should_not rspec_world.have_content(selector.capitalize)
                  end
                when :image, :images
                  one_or_all(locators).each do |selector|
                    session.should_not rspec_world.have_xpath("//img[@alt=\"#{selector}\"] | //img[@src=\"#{selector}\"]")
                  end
                when :field, :fields
                  one_or_all(locators).each do |locator|
                    session.should_not rspec_world.have_field(locator)
                  end
                when :link, :links
                  if locators.respond_to?(:each_pair)
                    locators.each_pair do |link_text, url|
                      session.should_not rspec_world.have_link(link_text, :href => url)
                    end
                  else
                    one_or_all(locators).each { |text| session.should_not rspec_world.have_link(text) }
                  end
                when :ordered
                  nodes = session.all(:xpath, locators.collect { |n| "//node()[text()= \"#{n}\"]" }.join(' | '))
                  nodes.map(&:text).should_not == locators
                when :readonly
                  one_or_all(locators).each do |selector|
                    if selector.respond_to?(:each_pair)
                      selector.each_pair do |text, locator|
                        see text => locator
                        session.find_field(locator)[value].should_not == ''
                      end
                    else
                      see :field => selector
                      session.find_field(selector)[value].should_not == ''
                    end
                  end
                when :empty
                  one_or_all(locators).each do |locator|
                    see :field => locator
                    session.find_field(locator).value.to_s.should_not == ''
                  end
                else
                  one_or_all(locators).each do |locator|
                    session.should_not rspec_world.have_field(locator, :with => value)
                  end
              end
            end
          else
            raise "Not Implemented Structure #{options} :: #{options.class}"
        end
      end
    end
  end
end
