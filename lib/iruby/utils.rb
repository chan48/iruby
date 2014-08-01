module IRuby
  class MimeString < String
    attr_reader :mime

    def initialize(mime, data)
      super(data.to_s)
      @mime = mime
    end

    def to_iruby
      [@mime, self]
    end
  end

  def self.display(obj, options = {})
    Kernel.instance.display(obj, options)
  end

  def self.table(obj, options = {})
    options[:maxrows] = 15 unless options.include?(:maxrows)
    return obj unless Enumerable === obj
    keys = nil
    size = 0
    rows = []
    obj.each_with_index do |row, i|
      row = row.flatten(1) if obj.respond_to?(:keys)
      if row.respond_to?(:keys)
        # Array of Hashes
        keys ||= Set.new
        keys.merge(row.keys)
      elsif row.respond_to?(:map)
        # Array of Arrays
        size = row.size if size < row.size
      end
      if options[:maxrows] && i > options[:maxrows]
        rows << '...'
        break
      end
      rows << row
    end
    table = '<table>'
    if keys
      keys.merge(0...size)
      table << '<tr>' << keys.map {|k| "<th>#{k}</th>"}.join << '</tr>'
    else
      keys = 0...size
    end
    rows.each do |row|
      table << '<tr>'
      if row.respond_to?(:map)
        row = keys.map {|k| "<td>#{row[k] rescue nil}</td>" }
        if row.empty?
          table << "<td#{keys.size > 1 ? " colspan='#{keys.size}'" : ''}></td>"
        else
          table << row.join
        end
      else
        table << "<td#{keys.size > 1 ? " colspan='#{keys.size}'" : ''}>#{row}</td>"
      end
      table << '</tr>'
    end
    html(table << '</table>')
  end

  def self.latex(s)
    MimeString.new('text/latex', s)
  end

  def self.math(s)
    MimeString.new('text/latex', "$$#{s}$$")
  end

  def self.html(s)
    MimeString.new('text/html', s)
  end

  def self.javascript(s)
    MimeString.new('application/javascript', s)
  end
end
