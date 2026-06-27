<!-- @format -->

<script>
/* global lsmbConfig */

import { defineComponent, ref } from "vue";
import { useI18n } from "vue-i18n";
import { createLoginMachine } from "./LoginPage.machines.js";

export default defineComponent({
    name: "LoginPage",
    props: ["successFn"],
    setup(props) {
        const { t } = useI18n({ useScope: "global" });
        let searchParams = new URL(document.location).searchParams;
        let username = searchParams.get("login") || lsmbConfig.demoUser || "";
        let company =
            searchParams.get("company") || lsmbConfig.demoCompany || "";
        let data = {
            password: ref(lsmbConfig.demoPassword || ""),
            username: ref(username),
            company: ref(company),
            form: ref(null),
            errorText: ref(""),
            successFn: (data) => {
                props.successFn(data);
            },
            t
        };
        let { service, state } = createLoginMachine(data);

        return {
            machine: service,
            version: window.lsmbConfig.version,
            state,
            ...data
        };
    },
    mounted() {
        document.body.setAttribute("data-lsmb-done", "true");
        this.machine.send("input");
    },
    methods: {
        update(e) {
            this[e.target.name] = e.target.value;
            this.machine.send("input", e);
        }
    }
});
</script>

<template>
    <!-- eslint-disable prettier/prettier -->
    <form id="login-form" ref="form" name="login">
        <div id="logindiv">
            <div class="login" align="center">
                <a href="http://www.ledgersmb.org/" target="_top">
                    <img
                        src="images/ledgersmb.png"
                        class="logo"
                        alt="LedgerSMB Logo"
                    >
                </a>
                <div id="maindiv" data-lsmb-done="true">
                    <div class="maindivContent">
                        <div>
                            <div id="company_div">
                                <lsmb-text
                                    id="username"
                                    name="username"
                                    size="20"
                                    :label="t('User Name')"
                                    :value="username"
                                    tabindex="1"
                                    autocomplete="off"
                                    required
                                    @keyup.enter="machine.send('submit')"
                                    @input="update"
                                />
                                <lsmb-password
                                    id="password"
                                    name="password"
                                    size="20"
                                    :label="t('Password')"
                                    :value="password"
                                    tabindex="2"
                                    autocomplete="off"
                                    required
                                    @keyup.enter="machine.send('submit')"
                                    @input="update"
                                />
                                <lsmb-text
                                    id="company"
                                    name="company"
                                    size="20"
                                    :label="t('Company')"
                                    tabindex="3"
                                    :value="company"
                                    @keyup.enter="machine.send('submit')"
                                    @input="update"
                                />
                            </div>
                            <lsmb-button
                                v-if="state !== 'failed'"
                                id="login"
                                tabindex="4"
                                :disabled="state !== 'ready'"
                                @click="machine.send('submit')"
                            >
                                {{ t("Login") }}
                            </lsmb-button>
                            <div v-else id="errorText">
                                {{ errorText }}
                            </div>
                        </div>
                    </div>
                </div>
                <transition>
                    <div v-if="state === 'submitting'">
                        {{ t("Logging in... Please wait.") }}
                    </div>
                </transition>
            </div>
        </div>
    </form>
    <h1 class="login" align="center">
        {{ version }}
    </h1>
</template>

<style scoped>
#login-form {
    max-width: fit-content;
}
#maindiv {
    min-width: max-content;
    height: 15em;
}
lsmb-select :deep(#username) {
    box-sizing: border-box;
    width: 100%;
}
lsmb-select :deep(#username td.dijitButtonContents.dijitStretch.dijitReset) {
    box-sizing: border-box;
    width: 100%;
}
</style>
