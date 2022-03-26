import Vue from "vue";
import App from "./App.vue";
import router from "./router";

Vue.config.productionTip = false;

import eruda from "eruda";
const lsDebug = localStorage.getItem("erudaDebug") == "init";
const uaDebug = navigator.userAgent.includes("erudaDebug");
if (lsDebug || uaDebug) {
  eruda.init();
}

new Vue({
  router,
  render: (h) => h(App),
}).$mount("#app");
