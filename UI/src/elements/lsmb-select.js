/** @format */

import { LsmbBaseInput } from "@/elements/lsmb-base-input";

const dojoSelect = require("dijit/form/Select");

export class LsmbSelect extends LsmbBaseInput {
    widgetWrapper = null;

    _stdProps() {
        return { size: 10 };
    }

    _widgetClass() {
        return dojoSelect;
    }

    _collectProps() {
        let props = super._collectProps();
        props.options = [];
        for (const child of this.children) {
            props.options.push({
                label: child.innerHTML,
                value: child.getAttribute("value"),
                selected: child.hasAttribute("selected")
            });
        }
        this.replaceChildren(); // delete all children
        return props;
    }
}

customElements.define("lsmb-select", LsmbSelect);
