Redmine::Plugin.register :redmine_operational_metrics do
  name 'Operational Metrics Plugin'
  author 'Antigravity'
  description 'A plugin to manage operational metrics'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :top_menu, :operational_metrics, { :controller => 'operational_metrics', :action => 'index' }, :caption => 'Operational Metrics'
  menu :top_menu, :tactical_meetings, { :controller => 'tactical_meetings', :action => 'index' }, :caption => 'Tactical Meetings'
end
