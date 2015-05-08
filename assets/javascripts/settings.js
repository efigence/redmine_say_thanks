function hideUnpermitted(permitted) {
  $('select.selekt-members').each(function(){
    var group_id = $(this).data('group-id');
    if ( $.inArray(group_id.toString(), permitted) == -1 ) {
      this.selectize.clear();
      $(this).parent().hide();
    } else {
      $(this).parent().show();
    }
  });
}

$(function(){
  $('.settings').removeClass('tabular');

  $select = $('.selectize').selectize({
    plugins: ['remove_button']
  });

  $('select#group_ids').selectize({
    plugins: ['remove_button'],
    onInitialize: function() {
      hideUnpermitted(this.items);
    },
    onChange: function(values) {
      hideUnpermitted(values);
    }
  });
});
