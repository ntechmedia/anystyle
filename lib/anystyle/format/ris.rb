module AnyStyle
  module Format
    module RIS
      def format_ris(dataset, **opts)
        format_hash(dataset).map { |entry| format_entry(entry) }.join("\n\n") + "\n"
      end

      def format_entry(entry)
        lines = []

        type = ris_type(entry[:type])
        lines << "TY  - #{type}"

        if (date = ris_py_value(entry))
          lines << date
        end

        add_authors(lines, entry[:author])
        # lines << "PY  - #{unwrap(entry[:issued] || entry[:date])}" if entry[:issued] || entry[:date]
        lines << "TI  - #{unwrap(entry[:title])}" if entry[:title]
        lines << "T2  - #{unwrap(entry[:'container-title'])}" if entry[:'container-title']
        lines << "PB  - #{unwrap(entry[:publisher])}" if entry[:publisher]
        lines << "SN  - #{unwrap(entry[:ISBN] || entry[:ISSN])}" if entry[:ISBN] || entry[:ISSN]
        lines << "DO  - #{unwrap(entry[:DOI])}" if entry[:DOI]
        lines << "UR  - #{unwrap(entry[:URL])}" if entry[:URL]
        lines << "ET  - #{unwrap(entry[:edition])}" if entry[:edition]
        lines << "CY  - #{unwrap(entry[:'publisher-place'] || entry[:location])}" if entry[:'publisher-place'] || entry[:location]
        lines << "VL  - #{unwrap(entry[:volume])}" if entry[:volume]
        lines << "IS  - #{unwrap(entry[:issue])}" if entry[:issue]
        lines << "SP  - #{unwrap(entry[:page].to_s.split('-')[0])}" if entry[:page]
        lines << "EP  - #{unwrap(entry[:page].to_s.split('-')[1])}" if entry[:page]&.include?("-")
        lines << "ER  -"

        lines.join("\n")
      end

      # Extended RIS type mapping
      def ris_type(type)
        case type.to_s.downcase
        when 'book'            then 'BOOK'  # Book
        when 'chapter'         then 'CHAP'  # Book chapter
        when 'article-journal' then 'JOUR'  # Journal article
        when 'magazine-article', 'magazine' then 'MGZN'  # Magazine
        when 'newspaper-article', 'news'    then 'NEWS'  # Newspaper
        when 'conference-paper', 'proceedings-article' then 'CONF'  # Conference
        when 'manuscript'      then 'UNPB'  # Unpublished
        when 'thesis'          then 'THES'  # Thesis/dissertation
        when 'webpage', 'electronic', 'online' then 'ELEC'  # Electronic source
        when 'film'            then 'MPCT'  # Motion picture
        when 'report'          then 'RPRT'  # Technical report
        else 'GEN' # Generic fallback
        end
      end

      def unwrap(val)
        val.is_a?(Array) ? val.first : val
      end

      def add_authors(lines, authors)
        return unless authors

        authors.each do |author|
          name = if author[:literal]
                  author[:literal]
                elsif author[:family] || author[:given]
                  family = author[:family]
                  given = author[:given]&.gsub('.', '')

                  # Add space between adjacent uppercase initials (e.g., "HJ" => "H J")
                  given = given.gsub(/(?<=\A|\s)([A-Z])(?=[A-Z])/, '\1 ') if given

                  [family, given].compact.join(', ')
                else
                  nil
                end

          lines << "AU  - #{name}" if name
        end
      end

      # Emit "YYYY/MM/DD/", leaving missing parts empty. Year is mandatory.
      def format_py(year, month = nil, day = nil)
        return nil unless year
        year_i = year.to_i
        month_s = month.nil? || month.to_s.strip.empty? ? "" : month.to_i.to_s
        day_s = day.nil? || day.to_s.strip.empty? ? "" : day.to_i.to_s
        "%04d/%s/%s/" % [year_i, month_s, day_s]
      end

      # Parse loose date strings into "YYYY/MM/DD/". Handles:
      def ris_py_value(entry)
        date_raw = unwrap(entry[:date])
      
        return nil if date_raw.nil?
        date_string = date_raw.to_s.strip
        return nil if date_string.empty?

        # Year only
        if date_string =~ /\A\d{4}\z/
          return "PY  - " + format_py(date_string.to_i)
        end

        # D/M/YYYY or DD-MM-YYYY
        if (matched = date_string.match(/\A(\d{1,2})[\/.-](\d{1,2})[\/.-](\d{4})\z/))
          day, month, year = matched[1].to_i, matched[2].to_i, matched[3].to_i
          return "DA  - " + format_py(year, month, day)
        end

        # YYYY-M-D or YYYY/M or YYYY/M/D
        if (matched = date_string.match(/\A(\d{4})[\/.-](\d{1,2})(?:[\/.-](\d{1,2}))?\z/))
          year, month, day = matched[1].to_i, matched[2].to_i, (matched[3] && matched[3].to_i)
          return "DA  - " + format_py(year, month, day)
        end

        # Fallback: extract a plausible year
        if (matched = date_string.match(/\b(1?[0-9]\d{2}|20\d{2})\b/))
          return "PY  - " + format_py(matched[1].to_i)
        end

        nil
      end
    end
  end
end