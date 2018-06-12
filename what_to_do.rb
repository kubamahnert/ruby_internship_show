load 'connection_opts.rb'
client = GoodData.connect *connection_opts
project, blueprint = create_simple_project 'internship test', client, proj_token

report = add_report(project, { what: 'fact.lines_changed', how: 'label.dev_email', title: 'Who worked the hardest?' })

dashboard = project.dashboards.first
tab = dashboard.tabs.first

tab.add_report_item({ report: report }.merge top_left_position)
dashboard.save

tab.add_report_item({ report: report }.merge top_right_position)

data = CSV.read 'commit_data.csv'
project.methods.grep /upload/
project.upload data, blueprint, 'commits'

# times demo
require 'faker'
5.times do
  dashboard.create_tab(title: Faker::Pokemon.move)
end
dashboard.save

# save patch
class GoodData::Dashboard
  def save
    puts "Do you really want to delete #{title}?"
    input = gets.chomp
    super if input == 'yes'
  end
end
dashboard.save
