Vue.component('message', {
  template: '#message_template',
  data() {
    return {};
  },
  computed: {
    textEscaped() {
      let s = this.template ? this.template : this.templates[this.templateId];

      //This hack is required to preserve backwards compatability
      if (this.templateId == CONFIG.defaultTemplateId
          && this.args.length == 1) {
        s = this.templates[CONFIG.defaultAltTemplateId] //Swap out default template :/
      }

      s = s.replace(/{(\d+)}/g, (match, number) => {
        const argEscaped = this.args[number] != undefined ? this.escape(this.args[number]) : match
        if (number == 0 && this.color) {
          if (this.color == 1) {
            return `<div class=stategained> <b>${argEscaped}</b> ` ;
          }
          if (this.color == 2) {
            return `<div class=tweet> <b>${argEscaped}</b> ` ;
          }
          if (this.color == 3) {
            return `<div class=emergency> <b>${argEscaped}</b> ` ;
          }  
          if (this.color == 4) {
            return `<div class=system> <b>${argEscaped}</b> ` ;
          }  
          if (this.color == 5) {
            return `<div class=smsfrom> <b>${argEscaped}</b> ` ;
          }  
          if (this.color == 6) {
            return `<div class=smsto> <b>${argEscaped}</b> ` ;
          }  
          if (this.color == 7) {
            return `<div class=action> <b>${argEscaped}</b> ` ;
          } 
          if (this.color == 8) {
            return `<div class=pager> <b>${argEscaped}</b> ` ;
          } 

          //color is deprecated, use templates or ^1 etc.
          return `<div class=system> <b>${argEscaped}</b> ` ;
        }
        return argEscaped;
      });
      return this.colorize(s);
    },
  },
  methods: {
    colorizeOld(str) {

    },
    colorize(str) {
      let s = "<span>" + (str.replace(/\^([0-9])/g, (str, color) => `</span><span class="color-white">`)) + "</span>";

      const styleDict = {
        '*': 'font-weight: bold;',
        '_': 'text-decoration: underline;',
        '~': 'text-decoration: line-through;',
        '=': 'text-decoration: underline line-through;',
        'r': 'text-decoration: none;font-weight: normal;',
      };

      const styleRegex = /\^(\_|\*|\=|\~|\/|r)(.*?)(?=$|\^r|<\/em>)/;
      while (s.match(styleRegex)) { //Any better solution would be appreciated :P
        s = s.replace(styleRegex, (str, style, inner) => `<em style="${styleDict[style]}">${inner}</em>`)
      }
      return s.replace(/<span[^>]*><\/span[^>]*>/g, '');
    },
    escape(unsafe) {
      return String(unsafe)
       .replace(/&/g, '&amp;')
       .replace(/</g, '&lt;')
       .replace(/>/g, '&gt;')
       .replace(/"/g, '&quot;')
       .replace(/'/g, '&#039;');
    },
  },
  props: {
    templates: {
      type: Object,
    },
    args: {
      type: Array,
    },
    template: {
      type: String,
      default: null,
    },
    templateId: {
      type: String,
      default: CONFIG.defaultTemplateId,
    },
    multiline: {
      type: Boolean,
      default: false,
    },
    color: { //deprecated
      type: Array,
      default: false,
    },
  },
});
