class Page

  TYPE = 'page'
  REPRESENTATION = 'storage'
  @document

  attr_reader :page_id, :title, :space_key, :document
  attr_writer :revision

  def initialize(space_key, title, document, page_id)
    @space_key = space_key
    @title = title
    @document = document
    @page_id = page_id
    @revision = nil
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

    page[:version] = {:number => @revision} unless @revision.nil?
    page[:id] = @page_id unless @page_id.nil?

    JSON.generate page
  end
end
