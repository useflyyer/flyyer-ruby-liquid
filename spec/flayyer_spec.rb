RSpec.describe FlayyerLiquid do
  it 'has a version number' do
    expect(FlayyerLiquid::VERSION).not_to be nil
  end
end

RSpec.describe FlayyerLiquid::FlayyerTag do
  before(:all) do
    Liquid::Template.register_tag('flayyer', FlayyerLiquid::FlayyerTag)
  end

  it "renders flayyer url with '' arguments" do
    template = Liquid::Template.parse("{% flayyer tenant: 'tenant', deck: 'deck', template: 'template' %}")
    href = template.render('flayyer_variables' => { title: 'Hello world!' })
    expect(href).to start_with('https://flayyer.host/v2/tenant/deck/template._.jpeg?__v=')
    expect(href).to end_with('&title=Hello+world%21')
  end

  it 'renders flayyer url with "" arguments' do
    template = Liquid::Template.parse('{% flayyer tenant: "tenant", deck: "deck", template: "template" %}')
    href = template.render('flayyer_variables' => { title: 'Hello world!' })
    expect(href).to start_with('https://flayyer.host/v2/tenant/deck/template._.jpeg?__v=')
    expect(href).to end_with('&title=Hello+world%21')
  end

  it 'renders flayyer url with plain arguments (not recommended)' do
    template = Liquid::Template.parse('{% flayyer tenant: tenant, deck: deck, template: template %}')
    href = template.render('flayyer_variables' => { title: 'Hello world!' })
    expect(href).to start_with('https://flayyer.host/v2/tenant/deck/template._.jpeg?__v=')
    expect(href).to end_with('&title=Hello+world%21')
  end

  it 'silently fails with missing required arguments (tenant, deck or template)' do
    formats = [
      "{% flayyer tenant: 'tenant' %}",
      "{% flayyer deck: 'deck', template: 'template' %}",
      '{% flayyer %}',
      "{% flayyer title: 'Hello world' %}",
    ]
    formats.each do |f|
      template = Liquid::Template.parse(f)
      href = template.render
      expect(href).to eq('')
    end
  end

  it 'silently fails with invalid format' do
    formats = [
      "{% flayyer { :template => 'template', :deck => 'deck', :template => 'template' } %}",
      "{% flayyer 'tenant': 'tenant', 'deck': 'deck', 'template': 'template' %}",
      "{% flayyer { template: 'template', deck: 'deck', template: 'template' } %}",
    ]
    formats.each do |f|
      template = Liquid::Template.parse(f)
      href = template.render
      expect(href).to eq('')
    end
  end

  it 'recieves pre-parsed values from liquid rendering engine' do
    template = Liquid::Template.parse("{% flayyer tenant: 'tenant', deck: 'deck', template: 'template', title: '{{ product.name }}', description: '{{ product.description }}' %}")
    href = template.render({ 'product' => { 'name' => 'Laptop', 'description' => 'This is a description!' } })
    expect(href).to start_with('https://flayyer.host/v2/tenant/deck/template._.jpeg?__v=')
    expect(href).to end_with('&title=Laptop&description=This+is+a+description%21')
  end

  it 'can set version and extension' do
    template = Liquid::Template.parse("{% flayyer tenant: 'tenant', deck: 'deck', template: 'template', version: 123, extension: 'png' %}")
    href = template.render
    expect(href).to start_with('https://flayyer.host/v2/tenant/deck/template.123.png?__v=')
  end

  it 'can pass extra arguments as variables' do
    template = Liquid::Template.parse("{% flayyer tenant: 't', deck: 'd', template: 't', title: 'Hello world!', description: 'Description' %}")
    href = template.render
    expect(href).to start_with('https://flayyer.host/v2/t/d/t._.jpeg?__v=')
    expect(href).to end_with('&title=Hello+world%21&description=Description')
  end
end
