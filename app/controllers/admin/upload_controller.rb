class Admin::UploadController < AdminController
	require 'rubyXL'
  require 'open3'
  include API::V2 
  include Imports

  def index
    @plan = current_market.plan.name # check if LocalEyes plan on market
    @current_mkt_id = current_market.id #TODO maybe useful
    # code for mapping organization and ensuring sign-in authenticated upload
    @org_ids = current_user.organizations.map(&:id)
    @curr_user = current_user.id # to pass along, will find user by id in get_org method


    # @products_avail = Product.where(organi

    ## no longer needed, TBD
  	#sql = "select subdomain, id from markets where id in (select destination_market_id from market_cross_sells where source_market_id=#{current_mkt_id});"
  	#records = ActiveRecord::Base.connection.execute(sql)
    # @job_id = Time.now.to_i # send this to the audit
  	# @suppliers_available = Hash.new
  	# records.each do |r|
  	# 	@suppliers_available[r['subdomain']] = {'market_id'=>r['id']}
  	# end
  end


  def upload
    if params.has_key?(:datafile)
      # pass the datafile to the method with the csv file
      jsn = ::Imports::SerializeProducts.get_json_data(params[:datafile],params[:curr_user]) # product stuff, row errors
      @num_products_loaded = 0
      unless jsn.include?("invalid")
        jsn[0]["products"].each do |p|
          ::Imports::ProductHelpers.create_product_from_hash(p,params[:curr_user])
          @num_products_loaded += 1
        end
        @errors = jsn[1]
      else
        @num_products_loaded = 0
        @errors = {"File"=>jsn}
      end

    end
  end
  
end