class Company {
  constructor(options) {
    this.selector = options.selector;
    this._init();
  }

  edit(trigger) {
    $.get($(trigger).attr('href'), {format: 'html'}, (html) => {
      const tr = $(trigger).closest('tr');
      tr.find('td').first().html(html);
      tr.find('td').last().find('a').hide();
      tr.find('td').last().find('button').show();
    });
  }

  update(trigger) {
    const form = $(trigger).closest('tr').find('form')[0];
    Rails.fire(form, 'submit');
  }

  cancel(trigger) {
    document.location.reload();
  }

  _init() {
    $(document).ready(() => {
      $(this.selector).find('button').hide();
    });
  }
}

hyacc.Company = Company;
