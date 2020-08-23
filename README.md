# flayyer-ruby-liquid (flayyer_liquid)

This gem is agnostic to any Ruby framework and is meant to be used alongside [shopify/liquid](https://github.com/Shopify/liquid).

To create a FLAYYER template please refer to: [flayyer.com](https://flayyer.com?ref=flayyer-ruby-liquid)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flayyer'
gem 'flayyer_liquid'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install flayyer flayyer_liquid
```

## Usage

After installing the gem you need to register our custom tag to render Flayyer urls. You can do this on any file you are setting up liquid or any config files that executes when starting up the application.

```ruby
require 'flayyer_liquid'

Liquid::Template.register_tag('flayyer', FlayyerLiquid::FlayyerTag)
```

Just for reference, the programmatic usage is:

```ruby
# Register tag
Liquid::Template.register_tag('flayyer', FlayyerLiquid::FlayyerTag)

# Set defaults
template = Liquid::Template.parse("{% flayyer tenant: 'tenant', deck: 'my-deck', template: 'post' %}")

# Set variables and also you can override defaults by prefixing liquid variables with `flayyer_`
url = template.render('flayyer_variables' => { title: 'Hello world!' })
url = template.render({ 'flayyer_variables' => { title: 'Hello world!' }, 'flayyer_template' => 'gallery', 'flayyer_extension' => 'png' })
```

For convenience, adicional variables passed to `{% flayyer ... %}` tag will be treated as Flayyer variables. This is useful if your Flayyer template has a title variable, here is an example:

```ruby
template = Liquid::Template.parse(
  "{% flayyer tenant: 't', deck: 'd', template: 'post', title: 'My Post' %}"
)
```

This works with Liquid variables:

```ruby
template = Liquid::Template.parse(
  "{% flayyer tenant: 't', deck: 'd', template: 'post', title: '{{ post.title }}' %}"
)
url = template.render('post' => { title: 'My Post' })
```

### Use quotes around Liquid variables

Prevent this common mistake:

```ruby
# This is wrong ❌
{% flayyer title: {{ post.title }} %}
```

```ruby
# This is correct ✅
{% flayyer title: '{{ post.title }}' %}
```

**IMPORTANT: variables must be serializable.**

## Liquid templates

Here is an example:

```html
<head>
  <meta
    property="og:image"
    content="{% flayyer tenant: 't', deck: 'd', template: 'product', title: '{{ product.title }}', description: '{{ product.description }}' %}"
  >
</head>
```

## Shopify Integration

> Based on https://shopify.github.io/liquid-code-examples/example/open-graph-tags

Feel free to change images sizes from the filter [`img_url`](https://shopify.dev/docs/themes/liquid/reference/filters/url-filters) depending of how your Flayyer templates renders each type of preview.

```html
{%- assign og_title = page_title -%}
{%- assign og_url = canonical_url -%}
{%- assign og_type = 'website' -%}
{%- assign og_description = page_description | default: shop.description | default: shop.name -%}

{%- if settings.share_image -%}
  {%- capture og_image_tags -%}
    <--! FLAYYER integration starts -->
    {%- assign original_image = settings.share_image | img_url: '1200x630' -%}
    <meta
      property="og:image"
      content="{% flayyer tenant: 'tenant', deck: 'deck', template: 'main', title: '{{ og_title }}', image: '{{ original_image }}' %}"
    >
    <--! FLAYYER integration ends -->
  {%- endcapture -%}
{%- endif -%}

{%- case template.name -%}
  {%- when 'product' -%}
    {%- assign og_title = product.title | strip_html -%}
    {%- assign og_type = 'product' -%}

    {%- if product.images.size > 0 -%}
      {%- capture og_image_tags -%}
        {%- for image in product.images limit:3 -%}
          <--! FLAYYER integration starts -->
          {%- assign original_image = image.src | product_img_url: '800x800' -%}
          <meta
            property="og:image"
            content="{% flayyer tenant: 'tenant', deck: 'deck', template: 'main', title: '{{ og_title }}', image: '{{ original_image }}' %}"
          >
          <--! FLAYYER integration ends -->
        {%- endfor -%}
      {%- endcapture -%}
    {%- endif -%}

  {%- when 'article' -%}
    {%- assign og_title = article.title | strip_html -%}
    {%- assign og_type = 'article' -%}
    {%- assign og_description = article.excerpt_or_content | strip_html -%}

    {%- if article.image -%}
      {%- capture og_image_tags -%}
        <--! FLAYYER integration starts -->
        {%- assign original_image = article.src | product_img_url: '800x800' -%}
        <meta
          property="og:image"
          content="{% flayyer tenant: 'tenant', deck: 'deck', template: 'main', title: '{{ og_title }}', description: '{{ og_description }}', image: '{{ original_image }}' %}"
        >
        <--! FLAYYER integration ends -->
      {%- endcapture -%}
    {%- endif -%}

  {%- when 'collection' -%}
    {%- assign og_title = collection.title | strip_html -%}
    {%- assign og_type = 'product.group' -%}

    {%- if collection.image -%}
      {%- capture og_image_tags -%}
        <--! FLAYYER integration starts -->
        {%- assign original_image = collection.src | product_img_url: '800x800' -%}
        <meta
          property="og:image"
          content="{% flayyer tenant: 'tenant', deck: 'deck', template: 'main', title: '{{ og_title }}', image: '{{ original_image }}' %}"
        >
        <--! FLAYYER integration ends -->
      {%- endcapture -%}
    {%- endif -%}

  {%- when 'password' -%}
    {%- assign og_title = shop.name -%}
    {%- assign og_url = shop.url -%}
    {%- assign og_description = shop.description | default: shop.name -%}

{%- endcase -%}

<meta property="og:site_name" content="{{ shop.name }}">
<meta property="og:url" content="{{ og_url }}">
<meta property="og:title" content="{{ og_title }}">
<meta property="og:type" content="{{ og_type }}">
<meta property="og:description" content="{{ og_description }}">

{%- if template.name == 'product' -%}
  <meta property="og:price:amount" content="{{ product.price | money_without_currency | strip_html }}">
  <meta property="og:price:currency" content="{{ shop.currency }}">
{%- endif -%}

{{ og_image_tags }}

{%- unless settings.social_twitter_link == blank -%}
  <meta name="twitter:site" content="{{ settings.social_twitter_link | split: 'twitter.com/' | last | prepend: '@' }}">
{%- endunless -%}

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{{ og_title }}">
<meta name="twitter:description" content="{{ og_description }}">
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flayyer/flayyer-ruby-liquid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
