class Page

  TYPE = 'page'
  REPRESENTATION = 'storage'
  @title
  @space_key
  @document

  def initialize(space_key, title, document)
    @space_key = space_key
    @title = title
    @document = document
  end

  def to_json
    page = {
        :type => TYPE,
        :title => @title,
        :space => {
            :key => @space_key
        },
        :body => {
            :storage => {
                :value => @document,
                :representation => REPRESENTATION
            }
        }
    }

    JSON.generate page
  end
end