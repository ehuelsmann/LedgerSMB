
export default {
  template: `
    <li>
<div style="display:inline-block; width: 100%" class="dijitTreeRow" v-bind:class="{ dijitTreeRowHover : hover }" @mouseenter="hover = true" @mouseleave="hover = false"  @click="toggle">
      <a @click="toggle" v-if="!item.module" :aria-expanded="open ? 'true' : 'false'">
        <span v-if="isFolder" class="dijitInline dijitTreeExpando" v-bind:class="{ dijitTreeExpandoOpened : open, dijitTreeExpandoClosed : !open, dijitTreeNodeHover : hover }"></span>{{item.label}}

      </a>
      <a @click="follow" v-if="item.module" :href="url">
        <span class="dijitInline dijitTreeExpando dijitTreeExpandoLeaf"></span>{{item.label}}
      </a>
</div>
    <ul v-if="expanded" class="dijitTreeNodeContainer">
      <menu-item
        v-for="child,indx in children"
        :item="child"
        :key="indx"
        :menudata="menudata"
        ></menu-item>
    </ul>
    </li>
  `,
  props: [
    'item',
    'menudata',
  ],
  name: 'menu-item',
  data() {
    return {
        open: false,
        hover: false,
    }
  },
  computed: {
    children() {
      const childr = this.menudata.filter(child => {
        return this.item.id === child.parent;
      });
      return childr;
    },
    isFolder() {
      return this.children.length > 0;
    },
    expanded() {
      if (this.children) {
        return this.open;
      }
      return false;
    },
    url() {
      var l = document.location.toString();
      l = l.substr(0,l.indexOf('#'));
      return l + '#' + this.item.module + '?'
        + this.item.args.join('&');
    },
    loader_url() {
        return this.item.module + '?'
            + this.item.args.join('&');
    }
  },
  methods: {
    toggle(event) {
        this.open = !this.open;
        if (event) {
            event.stopPropagation();
        }
    },
    follow(event) {
        event.preventDefault();
        dijit.registry.byId('maindiv').load_link(this.loader_url);
    },
  },
}
