require 'spec_helper'
require_relative '../../../lib/anystyle/format/ris'
module AnyStyle
  describe AnyStyle::Format::RIS do
    include AnyStyle::Format::RIS

    let(:ap) { Parser.new }

    # Mock of the format_hash method
    def format_hash(dataset)
      dataset
    end

    it 'formats a book reference in RIS format' do
      data = [{
        type: 'book',
        author: [{ family: 'Doe', given: 'John' }],
        date: '2023',
        title: 'The Great Emu War',
        publisher: 'Wiley',
        ISBN: '9780245839459',
        URL: 'https://example.com',
        edition: '1',
        'publisher-place': 'New York'
      }]

      output = format_ris(data)
      expect(output).to include("TY  - BOOK")
      expect(output).to include("AU  - Doe, John")
      expect(output).to include("TI  - The Great Emu War")
      expect(output).to include("PY  - 2023")
      expect(output).to include("SN  - 9780245839459")
      expect(output).to include("ER  -")
    end

    it 'formats a book reference with a date in RIS format' do
      data = [{
        type: 'book',
        author: [{ family: 'Lipson', given: 'Charles' }],
        date: '15/5/2011',
        title: 'Cite Right: A Quick Guide to Citation Styles',
        publisher: 'University of Chicago Press',
        ISBN: '9780226484648',
        edition: '1',
      }]

      output = format_ris(data)
      expect(output).to include("PY  - 2011///")
    end

    it 'formats a journal article reference with a date in RIS format' do
      data = [{
        type: 'article',
        author: [{ family: 'Keller', given: 'Maria Eugenia' }],
        date: '15-05-2011',
        title: 'Experts perspectives on shared responsibility for speed management: A thematic analysis informed by systems thinking',
        containertitle: 'Accident Analysis & Prevention',
        ISSN: '0001-4575',
        volume: '211',
      }]
    
      output = format_ris(data)
      expect(output).to include("PY  - 2011///")

    end

    let(:refs) {[
      'Derrida, J. (c.1967). L’écriture et la différence (1 éd.). Paris: Éditions du Seuil.',
      'Perec, Georges. A Void. London: The Harvill Press, 02/08/1995. p.108.',
      'Michael, Corvid. The sink hole. Australia: Wiley, 2023-06-05. p.400.',
    ]} 

    it 'Parse correctly formats a date in RIS format' do
      output = ap.parse(refs, format: 'ris', date_format: 'citeproc')

      expect(output).to include("PY  - 1967///")
      expect(output).to include("PY  - 1995///")
      expect(output).to include("PY  - 2023///")
    end

  end
end