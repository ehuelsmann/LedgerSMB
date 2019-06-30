
import MenuItem from './MenuItem.js'

export default {
  template: `
    <div class="dijitTreeContainer">
      <ul class="menu">
      <menu-item
        v-for="child,indx in children"
        :key="indx"
        :item="child"
        :menudata="menuitemData"
     ></menu-item>
     </ul>
    </div>
  `,
  props: [
    'source',
  ],
  data() {
    return {
      menuitemData: [],
    }
  },
  components: {
    MenuItem,
  },
  computed: {
    children() {
      const childr = this.menuitemData.filter(child => {
        return child.parent === 0;
      });
      return childr;

    }
  },
  async created() {
    const response = await axios.get(this.source);
    this.menuitemData = response.data;
  },

}
