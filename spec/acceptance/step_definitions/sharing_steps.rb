step 'I share the sched.do application with my Yammer network' do
  mock_out_yammer_api({name: 'Laila', id: 12345, return_type: 'user' })
  click_button 'Share'
end

step 'I share the sched.do app and get an error from the Yammer API' do
  mock_failed_yam_request
  click_button 'Share'
end

step 'I close the share sched.do modal' do
  find('.ui-dialog-titlebar-close').click
end

step 'I choose to share sched.do with the Yammer group :group_name' do |group_name|
  mock_out_yammer_api(name: group_name, id: 1, return_type: 'group')
  within('.share-event') do
    fill_in_autocomplete(group_name)
    choose_autocomplete('.name', group_name)
  end
end
