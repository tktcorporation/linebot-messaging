class Manager::Flex
  def self.set_flex(text, contents)
    flex_contents = contents[:items].map do |content|
      {
        type: 'button',
        style: 'secondary',
        action: content[:action]
      }
    end
    self.flex_frame('vertical', text, flex_contents)
  end

  def self.confirm_flex(text, contents)
    flex_contents = contents[:items].map do |content|
      {
        type: 'button',
        style: 'link',
        action: content[:action]
      }
    end
    self.flex_frame('horizontal', text, flex_contents)
  end

  def self.flex_frame(layout, text, flex_contents)
    #layoutは'vertical'か'horizontal'
    {
      type: 'flex',
      altText: text,
      contents: {
        type: 'bubble',
        body: {
          type: 'box',
          layout: layout,
          contents: [
            {
              type: "text",
              text: text,
              wrap: true,
              gravity: "center",
              align: "center",
              size: "xl"
            }
          ]
        },
        footer: {
          type: 'box',
          layout: 'vertical',
          spacing: 'md',
          contents: flex_contents
        }
      }
    }
  end
end