  return {
    name = "topgg-lua",
    version = "0.0.1",
    description = "A library for top.gg, in lua",
    tags = { "dbl", "topgg", "top.gg" },
    license = "MIT",
    author = { name = "matthewthechickenman", email = "65732060+matthewthechickenman@users.noreply.github.com" },
    homepage = "https://github.com/matthewthechickenman/topgg-lua",
    dependencies = {
      "creationix/coro-http@3.2.0"
    },
    files = {
      "**.lua",
      "!test*"
    }
  }
  