var env = process.env.ENV,
	agent_enabled = (env != 'development'),
	app_name = 'Bithub' + ' (' + process.env.ENV + ')';

exports.config = {
	app_name:      [app_name],
	agent_enabled: agent_enabled,
	license_key:   'fceb2642ac34bfe1de22a2a43bb9502a0ac48d8a',
	logging: {
		level: 'info'
	}
};
