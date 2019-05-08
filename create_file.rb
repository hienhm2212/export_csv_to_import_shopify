require 'csv'
require 'pry'

HEADERS = ["Handle","Title","Body (HTML)","Vendor","Type","Tags","Published","Option1 Name","Option1 Value","Option2 Name","Option2 Value","Option3 Name","Option3 Value","Variant SKU","Variant Grams","Variant Inventory Tracker","Variant Inventory Qty","Variant Inventory Policy","Variant Fulfillment Service","Variant Price","Variant Compare At Price","Variant Requires Shipping","Variant Taxable","Variant Barcode","Image Src","Image Position","Image Alt Text","Gift Card","SEO Title","SEO Description","Google Shopping / Google Product Category","Google Shopping / Gender","Google Shopping / Age Group","Google Shopping / MPN","Google Shopping / AdWords Grouping","Google Shopping / AdWords Labels","Google Shopping / Condition","Google Shopping / Custom Product","Google Shopping / Custom Label 0","Google Shopping / Custom Label 1","Google Shopping / Custom Label 2","Google Shopping / Custom Label 3","Google Shopping / Custom Label 4","Variant Image","Variant Weight Unit","Variant Tax Code","Cost per item"]

file_path = "/home/hien/hienhm/test"
file_input = file_path + "/input3.csv"
file_export = file_path + "/export.csv"
file_format = file_path + "/file_format.csv"


def get_data_from_file(file_input)
  last = ""
  data = []

  CSV.foreach(file_input) do |row|
    if row[-1].nil?
      row[-1] = last
    else
      last = row[-1]
    end
    data << row
  end
  data
end

def remove_nil_data(data)
  out = []
  data.each do |d|
    out << d.compact
  end
  out
end

# lay 5 phan tu 
def get_data_to_export(data)
  final = []
  data.each do |d|
    final << d[0..4].to_a
  end
  final
end

# doc format tu file ngoai
def read_format_file(file_format)
  row_format = []
  csv_text = File.read(file_format)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    row_format << row.to_hash
  end
  row_format.first
end

def format_line_2(format)
  line_2_fm = format.transform_values { |v| nil }
  line_2_fm['Option1 Value'] = "Sterling silver - 20 inches Chain"
  line_2_fm['Variant Grams'] = "0"
  line_2_fm['Variant Inventory Qty'] = "-105"
  line_2_fm['Variant Inventory Policy'] = "deny"
  line_2_fm['Variant Fulfillment Service'] = "manual"
  line_2_fm['Variant Price'] = "42.99"
  line_2_fm['Variant Compare At Price'] = "80.99"
  line_2_fm['Variant Requires Shipping'] = "true"
  line_2_fm['Variant Taxable'] = "true"
  line_2_fm['Variant Weight Unit'] = "kg"
  line_2_fm
end

def update_to_file_output(hash_data, file_export, format)
  default_format = format
  CSV.open(file_export, "wb") do |csv_out|
    csv_out << HEADERS
    hash_data.each do |h|
      handle = h[:title].downcase.gsub(/\W+/, '-')
      (1..4).each do |i|
        # line 1 se co title va full format
        if i == 1
          new_format = default_format
          new_format['Title'] = h[:title]
        end
        
        # line 2 se xai format rieng
        new_format = format_line_2(format) if i == 2
        
        # line 3 va 4 se cho tat ca cac gia tri la rong
        if [3,4].include? i
          new_format = format.transform_values { |v| nil }
        end
        
        key = ("img" + i.to_s).to_sym
        new_format['Handle'] = handle
        new_format['Image Src'] = h[key]
        new_format['Image Position'] = i
        csv_out << new_format.values
      end
    end
  end
end

# Get data from file input
data = get_data_from_file(file_input); data.count
# Remove nil value
data_not_nil = remove_nil_data(data); data_not_nil.count
# Get title and 4 images
data_final = get_data_to_export(data_not_nil); data_final.count
# Turn to hash
hash_data = []

data_final.each do |x|
  hash_data << [:title, :img1, :img2, :img3, :img4].zip([x[0],x[1],x[2],x[3],x[4]]).to_h
end

format = read_format_file(file_format)

# Export file
update_to_file_output(hash_data, file_export, format)

puts "Please get file export here: #{file_export} !!!"
