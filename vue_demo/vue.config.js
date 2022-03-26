const { defineConfig } = require("@vue/cli-service");

const isOfflineMode = process.env.VUE_APP_OFFLINE_OUTPUT_DIR == "distOffline";

module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: isOfflineMode ? "./" : "/",
  outputDir: isOfflineMode ? process.env.VUE_APP_OFFLINE_OUTPUT_DIR : "dist",
});
