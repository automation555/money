# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def amt_class(amt)
    rv='positive'
    if amt < 0
      rv='negative'
    end
    rv
  end

  def currency_span(amt, id=nil)
    i=id ? %W(id="#{id}") : ''
    "<span #{i} class=\"#{amt_class(amt)}\">#{number_to_currency(amt)}</span>"
  end

  # Singularize a word if the count is 1.
  def maybe_singular(cnt, word)
    cnt == 1 ? word.singularize : word
  end

  def txn_delete_tag(txn)
    link_to_remote(tag("img", {:src => '/images/trash.gif', :class => 'trash', :alt => '[delete]'}),
      :url => formatted_acct_txn_path(txn.account, txn, 'js'), :method => :delete)
  end
end
