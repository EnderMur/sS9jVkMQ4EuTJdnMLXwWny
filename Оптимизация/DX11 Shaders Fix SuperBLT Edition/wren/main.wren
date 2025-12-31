
import "base/native/DB_001" for DBManager, DBForeignFile
import "base/native/Environment_001" for Environment

var DX11hook1 = DBManager.register_asset_hook("core/shaders/post", "render_template_database")
DX11hook1.plain_file = "%(Environment.mod_directory)/core/shaders/post.render_template_database"

var DX11hook2 = DBManager.register_asset_hook("shaders/base", "render_template_database")
DX11hook2.plain_file = "%(Environment.mod_directory)/shaders/base.render_template_database"

var DX11hook3 = DBManager.register_asset_hook("core/shaders/deferred_lighting", "render_template_database")
DX11hook3.plain_file = "%(Environment.mod_directory)/core/shaders/deferred_lighting.render_template_database"

var DX11hook4 = DBManager.register_asset_hook("core/shaders/filters", "render_template_database")
DX11hook4.plain_file = "%(Environment.mod_directory)/core/shaders/filters.render_template_database"