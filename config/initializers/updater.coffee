AwesomeboxUpdater = Caboose.path.lib.join('awesomebox_updater').require()

Caboose.app.updater = new AwesomeboxUpdater()
Caboose.app.updater.start()
