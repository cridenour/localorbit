module Imports
	module SerializeProducts
		require 'csv'
		@all_headers = ["Organization","Market Subdomain","Product Name","Category Name","Short Description","Long Description","Product Code","Unit Name","Unit Description","Net Price","Price","New Inventory","Product ID", "Parent Product Name", "Organic", "Unit Quantity", "Lot Number"] # Required headers for imminent future
		@required_headers = ["Organization","Market Subdomain","Product Name","Category Name","Short Description","Product Code","Unit Name","Unit Description","Price","New Inventory","Product ID"] # Required headers for imminent future

		# TODO should this be a diff kind of accessor? Later, works.
		def self.required_headers
			@required_headers
		end

		def self.get_json_data(csvfile,current_user) # from - params[:filewhatever] from upload form
			$product_rows = {} # these are global
			$row_errors = {} # Collect errors here
			if self.validate_csv_catalog_file_format(csvfile)
				$product_rows["products"] = []
				CSV.foreach(csvfile.path, headers:true).each_with_index do |row, i| # i is the index of the row in the file
					if validate_product_row(row, i, current_user) # if the row is valid (see method)
						# then build a hash for it
						product_row_hash = {}
						@all_headers[0..14].each do |rh|
							product_row_hash[rh] = row[rh]
						end
						$product_rows["products"] << product_row_hash
					else
						# This is what happens if a row is invalid but the general format of the file is correct.
						# All rows should be displayed on upload. 
					end
					# TODO clarify return in diff scenarios
				end
				return $product_rows,$row_errors # array of these hashes
			else
			# Error handling
			# Return a message. TODO concern for redirects?
			$row_errors["0"] = "File format invalid. Upload requires a CSV with required headers." # TODO make this neater. 
			# OK that it is row 0 for now. Could be more specific with a "format" tag in yml/whatever and view tpl later.
			end
		end

		# takes a csvfile -- returns true if valid, false if invalid
		def self.validate_csv_catalog_file_format(csvfile)
			begin
				csvfile = CSV.parse(open(csvfile),headers:true)
				$product_rows["products_total"] = csvfile.size
				headers = csvfile.headers
				if csvfile.size < 1 # not counting headers -- if no data, false
					return false
				end
				@required_headers[0..10].each do |h| # if all the required headers aren't here, false
					unless headers.include?(h)
						return false
					end
				end
				true
			rescue
				$row_errors["0"] = "Invalid file format. Please try again with a valid .CSV file."
				return false
			end
		end

		def self.validate_product_row(product_row, line_num,current_user)
			okay_flag = true
			error_hash = {}
			## This shouldn't be needed for anything outside verifying CSV files uploaded. Check w
			error_hash["Row number"] = line_num.to_s 
			error_hash["Errors"] = {}
			if [product_row["Product Name"],product_row["Category Name"],product_row["Unit Name"],product_row["Price"]].any? {|obj| obj.blank?}
				okay_flag = false
				#create error and append it (TODO could have clearer error info for this one - which one is blank)
				error_hash["Errors"]["Invalid Data under required headers"] = "Some required data is blank."
			end
			#if product_row[@required_headers[-4]] and product_row[@required_headers[-4]].upcase == "Y" and [product_row[@required_headers[-3]],product_row[@required_headers[-2]],product_row[@required_headers.last]].any? {|obj| obj.blank?}
			#	okay_flag = false
			#	#create error and append it
			#	error_hash["Errors"]["Missing multi-unit/break case data"] = "#{@required_headers[-4]} header has data 'Y' but is missing required Unit and/or Price"
			#end
			if !product_row["Short Description"].nil? && product_row["Short Description"].length > 50
				okay_flag = false
				error_hash["Errors"]["Short Description too long"] = "Short description cannot be longer than 50 characters."
			end
			#if (!product_row[@required_headers[-4]] or product_row[@required_headers[-4]].upcase != "Y") and [product_row[@required_headers[-3]],product_row[@required_headers[-2]],product_row[@required_headers.last]].any? {|obj| !obj.blank?}
			#	okay_flag = false
			#	# create error and append it
			#	error_hash["Errors"]["Invalid data for #{@required_headers[-4]}"] = "Included multiple unit data without Y for #{@required_headers[-4]}"
			#end
			if ::Imports::ProductHelpers.get_category_id_from_name(product_row["Category Name"]).nil?
				okay_flag = false
				#create error and append it
				error_hash["Errors"]["Missing or invalid category"] = "Check category validity. Category of depth 2 (e.g. All -> Fruit -> Stone Fruit) required. Your input was: #{product_row["Category Name"]}" # TODO should have more info provided about category problems
			end
			if ::Imports::ProductHelpers.get_organization_id_from_name(product_row["Organization"], product_row["Market Subdomain"],current_user).nil?
				okay_flag = false
				#create error and append it
				error_hash["Errors"]["Missing or invalid Organization name"] = "Check organization and market subdomain validity. Do you have rights to upload to this organization in this market? Does this organization belong to this market subdomain?\n The organization name input was: #{product_row["Organization"]}\nThe market subdomain input was: #{product_row["Market Subdomain"]}" # TODO more info provided?
			end
			if ProductHelpers.get_unit_id_from_name(product_row["Unit Name"]).nil?
				okay_flag = false
				#create error and append it 
				error_hash["Errors"]["Missing or invalid Unit name"] = "Check unit of measure validity. Must be singular and included in LO system. Input was: #{product_row["Unit Name"]}" # TODO more info provided?
			end
			if !(product_row["Price"].to_f)
				okay_flag = false
				#create error and append it
				error_hash["Errors"]["Missing or invalid price"] = "Check product price validity. Must be a valid decimal. Input was: #{product_row["Price"]}"
			end
			#if !product_row["Unit Quantity"].nil? && !(product_row["Unit Quantity"].to_i and product_row["Unit Quantity"].to_i > 0)
			#		okay_flag = false
			#	error_hash["Errors"]["Invalid Unit Quantity"] = "Check unit quantity. Must be a valid number greater than or equal to 0. Input was: #{product_row["Unit Quantity"]}"
			#end
			if !product_row["Parent Product Name"].nil? && ProductHelpers.get_parent_product_id_from_name(product_row["Parent Product Name"], product_row["Organization"], product_row["Market Subdomain"], current_user).nil?
				okay_flag = false
				error_hash["Errors"]["Invalid Parent Product"] = "Specified Parent Product was not found. Your input was: #{product_row["Parent Product Name"]}" # TODO should have more info provided about category problems
			end
			#if product_row[@required_headers[-4]] and product_row[@required_headers[-4]].upcase == "Y" and product_row[@required_headers.last].to_f <= 0
			#	okay_flag = false
			#	error_hash["Errors"]["Missing or invalid price for additional pack size"] = "Check price validity for #{product_row[@required_headers.last]}. Must be a valid decimal > 0. Input was: #{product_row[@required_headers.last]}"
			#end
			#if (product_row[@required_headers[-4]] and product_row[@required_headers[-4]].upcase == "Y") and ([product_row[@required_headers[-3]],product_row[@required_headers[-2]],product_row[@required_headers.last]] == [product_row["Unit Name"],product_row["Unit Price"]])
			#	okay_flag = false
			#	error_hash["Errors"]["Identical units for same product"] = "Your additional unit and original unit for this project are the same. Try again with different information in the last three columns OR do not submit additional unit information."
			#end
			$row_errors["#{error_hash['Row number']}"] = error_hash

			return okay_flag 
			# Should return true if checks all pass.
		end

	end
end