hyacc._dialogs = new Stack();
hyacc.current_dialog = function(options) {
  return this._dialogs.top() || new hyacc.Dialog(options);
};

class Dialog {
  constructor(options = {}) {
    this.options = options;
    this.title = options.title;
    hyacc._dialogs.push(this);
  }

  _init_buttons() {
    const ret = [];

    if (this.options.buttons) {
      for (const button of this.options.buttons) {
        ret.push(button);
      }
    }

    if (this.options.submit) {
      ret.push({
        text: this.options.submit,
        class: 'btn btn-light',
        click: () => {
          const form = this.jq_dialog.dialog('widget').find('form').first()[0];
          Rails.fire(form, 'submit');
        }
      });
    }

    ret.push({
      text: '閉じる',
      class: 'btn btn-light',
      click: () => {
        this.close();
      }
    });

    return ret;
  }

  open(url) {
    $.get(url, (html) => {
      this.show(html);
    });
  }

  show(html) {
    if (this.jq_dialog) {
      this.jq_dialog.html(html);
    } else {
      this.jq_dialog = $(`<div class="dialog_wrapper">${html}</div>`).dialog({
        modal: true,
        title: this.title,
        width: this.options.width || 'auto',
        open: this.options.open || function() {
          // jQuery UI sets `this` to the dialog element here — must stay a regular function
          $(this).dialog('widget').find('.ui-dialog-titlebar button').last().focus();
        },
        close: () => {
          this.close();
        },
        buttons: this._init_buttons()
      });
    }
  }

  close() {
    hyacc._dialogs.pop();
    this.jq_dialog.dialog('destroy');
  }
}

hyacc.Dialog = Dialog;
