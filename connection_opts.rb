require 'gooddata'

def connection_opts
  ['rubydev+admin@gooddata.com', 'jindrisska123', { server: 'https://staging2-lcm-prod.intgdc.com', verify_ssl: false }]
end

def domain_name
  'staging2-lcm-prod'
end

def proj_token
  'CRALTINECKUM'
end

def create_simple_project(title, client, token)
  puts 'fresh'
  puts 'version is'
  puts GoodData.version

  blueprint = GoodData::Model::ProjectBlueprint.build(title) do |p|
    p.add_date_dimension('committed_on')
    p.add_dataset('devs') do |d|
      d.add_anchor('attr.dev')
      d.add_label('label.dev_id', :reference => 'attr.dev')
      d.add_label('label.dev_email', :reference => 'attr.dev')
    end
    p.add_dataset('commits') do |d|
      d.add_anchor('attr.commits_id')
      d.add_fact('fact.lines_changed')
      d.add_fact('fact.coffee_cups')
      d.add_date('committed_on')
      d.add_reference('devs')
    end
  end
  project = GoodData::Project.create_from_blueprint(blueprint, auth_token: token, client: client)

  # Load data
  commits_data = [
      ['fact.lines_changed', 'fact.coffee_cups' ,'committed_on', 'devs'],
      [1, 3, '01/01/2014', 1],
      [3, 2, '01/02/2014', 2],
      [5, 1, '05/02/2014', 3]]

  [["fact.lines_changed", "fact.coffee_cups", "committed_on", "devs"], ["1", "3", "01/01/2018", "1"], ["3", "1", "01/01/2018", "2"], ["2", "3", "01/01/2018", "3"], ["1", "1", "01/01/2018", "2"], ["2", "2", "01/01/2018", "3"], ["55", "12", "01/01/2018", "2"], ["12", "3", "01/01/2018", "1"], ["3", "4", "01/01/2018", "2"], ["1", "4", "01/01/2018", "1"], ["2", "1", "01/01/2018", "2"], ["2", "2", "01/01/2018", "3"], ["2", "2", "01/01/2018", "1"]]
  project.upload(commits_data, blueprint, 'commits')

  devs_data = [
      ['label.dev_id', 'label.dev_email'],
      [1, 'tomas@gooddata.com'],
      [2, 'petr@gooddata.com'],
      [3, 'jirka@gooddata.com']]
  project.upload(devs_data, blueprint, 'devs')

  # create a metric
  metric = project.facts('fact.lines_changed').create_metric title: 'line_count'
  metric = project.facts('fact.lines_changed').create_metric title: 'line_count'
  metric.lock
  metric.save

  ########################
  # Create new dashboard #
  ########################
  dashboard = project.create_dashboard(:title => 'Test Dashboard', client: client)

  tab = dashboard.create_tab(:title => 'Tab Title #1')

  dashboard.lock
  dashboard.save

  puts "Created project #{project.pid}"
  project
end

def add_metric(project)
  label = project.labels 'label.dev_email'
  metric = project.metric_by_title 'line_count'

  report = project.create_report(title: 'Who did the most commits?', top: [metric], left: ['label.dev_email'], format: 'chart', chart_part: { value_uri: label.uri })
  report.lock
  report.save

  dashboard = project.dashboards.first
  tab = dashboard.tabs.first

  tab.add_report_item(:report => report, :position_x => 10, :position_y => 20, size_y: 450, size_x: 400)
  dashboard.lock
  dashboard.save
end
