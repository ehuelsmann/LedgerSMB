/** @format */

import { createVuetify } from "vuetify";
import * as components from "vuetify/components";
import * as directives from "vuetify/directives";

import "@mdi/font/css/materialdesignicons.css"; // Import Material Design Icons

export default createVuetify({
    // Your Vuetify configuration options here
    components,
    directives,
    theme: {
        defaultTheme: "light"
    }
});
