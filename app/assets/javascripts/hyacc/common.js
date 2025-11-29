function findElementByClassName( elem, className ) {
    for ( var i = 0; i < elem.childNodes.length; i ++ ) {
      var child = elem.childNodes[i];
      if ( child.getAttributeNode == undefined ) {
        continue;	
      }
			
	  var clazz = child.getAttributeNode('class');
      if ( clazz != null && clazz.value == className ) {
        return child;
      }
    }
    
    return null;
}

function isEmpty( string ) {
	return string == null || string.length == 0;	
}

function getWindowSize() {
  if (document.all) {
    return [document.body.clientWidth, document.body.clientHeight];
  } else {
    return [window.innerWidth, window.innerHeight];
  }
}

function get_ymd_shortcut_enabled_form(target) {
  let form = $(target).closest('.ymd_shortcut_enabled');
  if (form.length === 0) {
    form = $('.ymd_shortcut_enabled').first();
  }
  return form;
}

function enable_ymd_shortcut(e) {
  Mousetrap.bindGlobal('ctrl+y', function(e) {
    e.preventDefault();
    let form = get_ymd_shortcut_enabled_form(e.target);
    form.find('input[name*=\\[ym\\]]').animate({scrollTop: 0}, 'fast').focus().select();
  });

  Mousetrap.bindGlobal('ctrl+d', function(e) {
    e.preventDefault();
    let form = get_ymd_shortcut_enabled_form(e.target);
    form.find('input[name*=\\[day\\]]').animate({scrollTop: 0}, 'fast').focus().select();
  });
}

// 参考：http://www.geocities.co.jp/SiliconValley/4334/unibon/javascript/formatnumber.html
// (すべての変数に格納する値は0オリジンとする) 
function toAmount( amount ) { // 引数の例としては 95839285734.3245
    var s = "" + amount; // 確実に文字列型に変換する。例では "95839285734.3245"
    var p = s.indexOf("."); // 小数点の位置を0オリジンで求める。例では 11
    if (p < 0) { // 小数点が見つからなかった時
        p = s.length; // 仮想的な小数点の位置とする
    }
    var r = s.substring(p, s.length); // 小数点の桁と小数点より右側の文字列。例では ".3245"
    for (var i = 0; i < p; i++) { // (10 ^ i) の位について
        var c = s.substring(p - 1 - i, p - 1 - i + 1); // (10 ^ i) の位のひとつの桁の数字。例では "4", "3", "7", "5", "8", "2", "9", "3", "8", "5", "9" の順になる。
        if (c < "0" || c > "9") { // 数字以外のもの(符合など)が見つかった
            r = s.substring(0, p - i) + r; // 残りを全部付加する
            break;
        }
        if (i > 0 && i % 3 == 0) { // 3 桁ごと、ただし初回は除く
            r = "," + r; // カンマを付加する
        }
        r = c + r; // 数字を一桁追加する。
    }
    return r; // 例では "95,839,285,734.3245"
}

function toFloat( amount ) {
  if ( amount == null || amount.length == 0 ) return 0;
  return parseFloat( amount.replace(/,/g, "") );
}

function toInt( amount ) {
  if ( amount == null || amount.length == 0 ) return 0;
  return parseInt( amount.replace(/,/g, "") );
}

/**
 * セレクトボックス内のオプションを入れ替えます。
 * 
 * @param {String} selectId セレクトボックスのID
 * @param {Object} jsonText JSONテキスト、またはJSONオブジェクト
 * @param {Boolean} includeBlank 先頭にブランクオプションを追加するかどうか
 */
function replaceOptions(selectId, jsonText, includeBlank){
  var json = jsonText;
  if ( typeof jsonText == 'string' || (typeof jsonText == 'object' && jsonText.constructor == String) ) {
    json = eval(jsonText);
  }

  var select = document.getElementById(selectId);

  if (json == null || json.length == 0) {
    select.value = "";
    select.options.length = 0;
    select.hide();
  }
  else {
    select.show();
    select.value = "";
    select.options.length = 0;

    if (includeBlank) {
  	  select.options[select.options.length] = new Option("", "");
    }
    
    for (var i = 0; i < json.length; i++) {
  	  select.options[select.options.length] = new Option(json[i].name, json[i].id);  
    }
  }  
}

function replace_options(selector, json, include_blank) {
  select = $(selector);
  select.empty();
  
  if (json.length > 0) {
    if (include_blank) {
      select.append('<option value=""></option>');
    }

    for (var i = 0; i < json.length; i ++) {
      select.append('<option value="' + json[i].id + '">' + json[i].name + '</option>');
     }

    select.show();

  } else {
    select.hide();
  }
};

// 日付の妥当性チェック
function checkDate(year, month, day){
  var date = new Date(year, month - 1, day);
  return (date.getFullYear() == year && date.getMonth()== month - 1 && date.getDate() == day);
};
