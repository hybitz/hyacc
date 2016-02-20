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

// 
/**
 * 同じName属性を持つチェックボックスのうち１つだけが選択されているかチェックします。
 * 
 * @param {Form} form フォーム
 * @param {String} elementName チェックボックスのName属性
 * @param {String} message エラー時に表示するメッセージ
 * @return true：1つだけ選択されているか何も選択されていない場合、false：2つ以上選択されている場合
 */
function checkExclusive( form, elementName, message ) {
  var checkedCount = 0;
  for ( var i = 0; i < form.elements.length; i ++ ) {
    var elem = form.elements[i];
    if ( ! elem.name ) continue;
    if ( elem.name == elementName && elem.checked ) {
      checkedCount ++;
    }
  }
  
  if ( checkedCount > 1 ) {
    alert(message);
    return false;
  }
  
  return true;
}

// 日付の妥当性チェック
function checkDate(year, month, day){
  var date = new Date(year, month - 1, day);
  return (date.getFullYear() == year && date.getMonth()== month - 1 && date.getDate() == day);
};

