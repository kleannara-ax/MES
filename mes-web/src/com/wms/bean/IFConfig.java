package com.wms.bean;

import java.math.BigDecimal;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;

import com.common.bean.DataMap;
import com.common.bean.FileRepository;
import com.common.util.FileUtil;
public class IFConfig {
	
	@Autowired
	private FileRepository respository;
	
	//private DataMap targetMap;
	Properties restful;
	private DataMap emptyMap;
	private DataMap intergerMap;
	private DataMap stringMap;
	private DataMap dateMap;

	public IFConfig(){
		setConfig();
	}

	public void setConfig(){
		FileUtil fileUtil = new FileUtil();
		restful = fileUtil.loadProperties(respository.getRoot()+"WEB-INF/conf", "restful.properties");
		
		//targetMap = new DataMap();
		 
		//DEV
//		targetMap.put("asnResult", "http://172.30.217.59/api/InboundInterface/AsnResult");
//		targetMap.put("orderReturnResult", "http://172.30.217.59/api/InboundInterface/OrderReturnResult");
//		targetMap.put("orderResult", "http://172.30.217.59/api/InboundInterface/OrderResult");
//		targetMap.put("orderstatus", "http://172.30.217.59/api/InboundInterface/OrderStatus");
//		targetMap.put("skuStock", "http://172.30.217.59/api/InboundInterface/SkuStock");
//		targetMap.put("skuLot", "http://172.30.217.59/api/InboundInterface/SkuLot");
//		targetMap.put("stockTransferResult", "http://172.30.217.59/api/InboundInterface/StockTransferResult");
		
		//REAL
		
//		targetMap.put("asnResult", "http://openif.esmplus.com/api/InboundInterface/AsnResult");
//		targetMap.put("orderReturnResult", "http://openif.esmplus.com/api/InboundInterface/OrderReturnResult");
//		targetMap.put("orderResult", "http://openif.esmplus.com/api/InboundInterface/OrderResult");
//		targetMap.put("orderstatus", "http://openif.esmplus.com/api/InboundInterface/OrderStatus");
//		targetMap.put("skuStock", "http://openif.esmplus.com/api/InboundInterface/SkuStock");
//		targetMap.put("skuLot", "http://openif.esmplus.com/api/InboundInterface/SkuLot");
//		targetMap.put("stockTransferResult", "http://openif.esmplus.com/api/InboundInterface/StockTransferResult");
//		
		
		emptyMap = new DataMap();
		
		DataMap asn = new DataMap();
		asn.put("BarcodeServiceYn","BarcodeServiceYn");
		asn.put("CarType","CarType");
		asn.put("EfmIfSeq","EfmIfSeq");
		asn.put("EfmMasterId","EfmMasterId");
		asn.put("EfmSkuStockCode","EfmSkuStockCode");
		asn.put("OrderType","OrderType");
		asn.put("InspectMethodType","InspectMethodType");
		asn.put("IwScheduledDate","IwScheduledDate");
		asn.put("IwScheduledQty","IwScheduledQty");
		asn.put("ToDistrCenterType","ToDistrCenterType");
		asn.put("ToStorageType","ToStorageType");
		asn.put("SkuId","SkuId");
		asn.put("SkuMatchingSeq","SkuMatchingSeq");
		asn.put("Status","Status");
		asn.put("WarehouseNo","WarehouseNo");
		emptyMap.put("asn",asn);
		
		DataMap seller = new DataMap();
		seller.put("EfmIfSeq","EfmIfSeq");
		seller.put("EfmMasterId","EfmMasterId");
		seller.put("EsmLoginId","EsmLoginId");
		seller.put("SellerType","SellerType");
		seller.put("SellerType2","SellerType2");
		seller.put("TplStatusCode","TplStatusCode");
		emptyMap.put("seller",seller);
		
		DataMap category = new DataMap();
		category.put("CategoryCode","CategoryCode");
		category.put("CategoryLCode","CategoryLCode");
		category.put("CategoryLevel","CategoryLevel");
		category.put("CategoryLname","CategoryLname");
		category.put("EfmIfSeq","EfmIfSeq");
		category.put("UseYn","UseYn");
		emptyMap.put("category",category);
		
		DataMap skuinfo = new DataMap();
		skuinfo.put("Barcode1","Barcode1");
		skuinfo.put("EfmIfSeq","EfmIfSeq");
		skuinfo.put("EfmMasterId","EfmMasterId");
		skuinfo.put("ExpireDateDays","ExpireDateDays");
		skuinfo.put("ExpireDateManageYn","ExpireDateManageYn");
		skuinfo.put("SkuId","SkuId");
		skuinfo.put("SkuName","SkuName");
		emptyMap.put("skuinfo",skuinfo);
		
		
		DataMap bigdeal = new DataMap();
		bigdeal.put("BigDealInfo","BigDealInfo");
		bigdeal.put("EfmIfSeq","EfmIfSeq");
		bigdeal.put("EndDate","EndDate");
		bigdeal.put("SkuId","SkuId");
		bigdeal.put("StartDate","StartDate");
		emptyMap.put("bigdeal",bigdeal);
		
		DataMap skuaddinfo = new DataMap();
		skuaddinfo.put("BundlePackYn","BundlePackYn");
		skuaddinfo.put("Heteromorphy","Heteromorphy");
		skuaddinfo.put("EfmIfSeq","EfmIfSeq");
		skuaddinfo.put("OwUnitCode","OwUnitCode");
		skuaddinfo.put("Height","Height");
		skuaddinfo.put("PackingIwQty","PackingIwQty");
		skuaddinfo.put("PackingNeedYn","PackingNeedYn");
		skuaddinfo.put("SkuId","SkuId");
		skuaddinfo.put("Vertical","Vertical");
		skuaddinfo.put("Weight","Weight");
		skuaddinfo.put("Width","Width");
		emptyMap.put("skuaddinfo",skuaddinfo);

		DataMap skustatus = new DataMap();
		skustatus.put("EfmIfSeq","EfmIfSeq");
		skustatus.put("SkuId","SkuId");
		skustatus.put("SkuStatusCode","SkuStatusCode");
		emptyMap.put("skustatus",skustatus);
		
		DataMap returnAsn = new DataMap();
		returnAsn.put("BuyerClaimAplnReason","BuyerClaimAplnReason");
		returnAsn.put("BuyerInfoCp","BuyerInfoCp");
		returnAsn.put("BuyerInfoHt","BuyerInfoHt");
		returnAsn.put("BuyerInfoNa","BuyerInfoNa");
		returnAsn.put("CartNo","CartNo");
		returnAsn.put("InvoiceNo","InvoiceNo");
		returnAsn.put("DeliveryExpenseType","DeliveryExpenseType");
		returnAsn.put("DistrCenterType","DistrCenterType");
		returnAsn.put("EfmIfSeq","EfmIfSeq");
		returnAsn.put("GoodsName","GoodsName");
		returnAsn.put("OrderType","OrderType");
		returnAsn.put("SkuQty","SkuQty");
		returnAsn.put("RcverInfoHt","RcverInfoHt");
		returnAsn.put("RcverInfoNa","RcverInfoNa");
		returnAsn.put("RefundType","RefundType");
		returnAsn.put("ReturnInvoiceNo","ReturnInvoiceNo");
		returnAsn.put("SiteGoodsNo","SiteGoodsNo");
		returnAsn.put("SiteId","SiteId");
		returnAsn.put("SiteOrderNo","SiteOrderNo");
		returnAsn.put("SkuId","SkuId");
		returnAsn.put("StorageType","StorageType");
		returnAsn.put("WarehouseNo","WarehouseNo");
		emptyMap.put("returnAsn",returnAsn);

		DataMap returnAsnCancel = new DataMap();
		returnAsnCancel.put("CartNo","CartNo");
		returnAsnCancel.put("BuyerClaimAplnReason","BuyerClaimAplnReason");
		returnAsnCancel.put("InvoiceNo","InvoiceNo");
		returnAsnCancel.put("DistrCenterType","DistrCenterType");
		returnAsnCancel.put("EfmIfSeq","EfmIfSeq");
		returnAsnCancel.put("GoodsName","GoodsName");
		returnAsnCancel.put("SkuQty","SkuQty");
		returnAsnCancel.put("SiteGoodsNo","SiteGoodsNo");
		returnAsnCancel.put("SiteId","SiteId");
		returnAsnCancel.put("SiteOrderNo","SiteOrderNo");
		returnAsnCancel.put("SkuId","SkuId");
		returnAsnCancel.put("WarehouseNo","WarehouseNo");
		emptyMap.put("returnAsnCancel",returnAsnCancel);
		
		DataMap order = new DataMap();
		order.put("CartNo","CartNo");
		order.put("GoodsQty","GoodsQty"); 
		order.put("OutboundType","OutboundType");
		order.put("DeliveryType","DeliveryType");                               
		order.put("DistrCenterType","DistrCenterType");                            
		order.put("EfmIfSeq","CartEfmIfSeqNo");                                   
		order.put("GiftYn","GiftYn");                                     
		order.put("GoodsName","GoodsName");                                  
		order.put("ZipCode","ZipCode");                                    
		order.put("RcverInfoAd1","RcverInfoAd1");                               
		order.put("RcverInfoHt","RcverInfoHt");                                
		order.put("RcverInfoNa","RcverInfoNa");                                
		order.put("SiteGoodsNo","SiteGoodsNo");                                
		order.put("SiteId","SiteId");                                     
		order.put("SiteOrderNo","SiteOrderNo");                                
		order.put("SkuId","SkuId");                                      
		order.put("WarehouseNo","WarehouseNo");                                
		order.put("WmsOrderCartonLine","WmsOrderCartonLine");                         
		order.put("WmsOrderNo","WmsOrderNo");                                 
		emptyMap.put("order",order);
		
		
		
		DataMap orderChange = new DataMap();
		orderChange.put("CartNo","CartNo");   
		orderChange.put("DistrCenterType","DistrCenterType");  
		orderChange.put("EfmIfSeq","EfmIfSeq");  
		orderChange.put("RcverInfoAd2","RcverInfoAd2");  
		orderChange.put("RcverInfoCp","RcverInfoCp");  
		orderChange.put("ZipCode","ZipCode");  
		orderChange.put("RcverInfoAd1","RcverInfoAd1");   
		orderChange.put("RcverInfoHt","RcverInfoHt");  
		orderChange.put("RcverInfoNa","RcverInfoNa");  
		orderChange.put("SiteId","SiteId");  
		orderChange.put("SiteOrderNo","SiteOrderNo");  
		orderChange.put("WarehouseNo","WarehouseNo");
		orderChange.put("WmsOrderNo","WmsOrderNo");  
		emptyMap.put("orderChange",orderChange);
		
		DataMap orderCancel = new DataMap();
		orderCancel.put("CartNo","CartNo"); 
		orderCancel.put("DistrCenterType","DistrCenterType"); 
		orderCancel.put("EfmIfSeq","EfmIfSeq"); 
		orderCancel.put("SkuQty","SkuQty"); 
		orderCancel.put("SiteId","SiteId"); 
		orderCancel.put("SiteOrderNo","SiteOrderNo"); 
		orderCancel.put("SkuId","SkuId"); 
		orderCancel.put("WarehouseNo","WarehouseNo"); 
		orderCancel.put("WmsOrderNo","WmsOrderNo"); 
		emptyMap.put("orderCancel",orderCancel);
		
		DataMap stockTransfer = new DataMap();
		stockTransfer.put("FromDistrCenterType","FromDistrCenterType"); 
		stockTransfer.put("DeliveryFeeType","DeliveryFeeType");
		stockTransfer.put("EfmIfSeq","EfmIfSeq");
		stockTransfer.put("EfmMasterId","EfmMasterId");
		stockTransfer.put("EfmSkuStockCode","EfmSkuStockCode");
		stockTransfer.put("OrderType","OrderType");
		stockTransfer.put("OutCode","OutCode"); 
		stockTransfer.put("Qty","Qty");
		stockTransfer.put("ReqDate","ReqDate");
		stockTransfer.put("SkuId","SkuId");
		stockTransfer.put("SkuMatchingSeq","SkuMatchingSeq");
		stockTransfer.put("TakeInfoAd1","TakeInfoAd1");
		stockTransfer.put("TakeInfoAd2","TakeInfoAd2"); 
		stockTransfer.put("TakeInfoCp","TakeInfoCp");
		stockTransfer.put("TakeInfoHt","TakeInfoHt");
		stockTransfer.put("TakeInfoNa","TakeInfoNa");
		stockTransfer.put("TakeZipCode","TakeZipCode");
		stockTransfer.put("WarehouseNo","WarehouseNo");
		emptyMap.put("stockTransfer",stockTransfer);
		
		
		DataMap stockTransferCancel = new DataMap();
		stockTransferCancel.put("EfmIfSeq","EfmIfSeq");
		stockTransferCancel.put("EfmMasterId","EfmMasterId");
		stockTransferCancel.put("ReqQty","ReqQty");
		stockTransferCancel.put("SkuId","SkuId");
		stockTransferCancel.put("SkuMatchingSeq","SkuMatchingSeq");
		stockTransferCancel.put("WarehouseNo","WarehouseNo");
		emptyMap.put("stockTransferCancel",stockTransferCancel);
		
		DataMap skuLot = new DataMap();
		skuLot.put("SkuId", "SkuId");
		emptyMap.put("skuLot",skuLot);
		
		intergerMap = new DataMap();
		intergerMap.put("EfmIfSeq","EfmIfSeq");
		intergerMap.put("EfmMasterId","EfmMasterId");
		intergerMap.put("SellerType","SellerType");
		intergerMap.put("SellerType2","SellerType2");
		intergerMap.put("SkuId","SkuId");
		intergerMap.put("ExpireDateDays","ExpireDateDays");
		intergerMap.put("ExpireDateNearDays","ExpireDateNearDays");
		intergerMap.put("ExpireDateRiskDays","ExpireDateRiskDays");
		intergerMap.put("OwUnitCode","OwUnitCode");
		intergerMap.put("PackingIwQty","PackingIwQty");
		intergerMap.put("Heteromorphy","Heteromorphy");
		intergerMap.put("SkuGrade","SkuGrade");
		intergerMap.put("OrderType","OrderType");
		intergerMap.put("CarType","CarType");
		
		intergerMap.put("WarehouseNo","WarehouseNo");
		intergerMap.put("Status","Status");
		intergerMap.put("FromDistrCenterType","FromDistrCenterType");
		intergerMap.put("ToDistrCenterType","ToDistrCenterType");
		intergerMap.put("ToStorageType","ToStorageType");
		intergerMap.put("SkuMatchingSeq","SkuMatchingSeq");
		intergerMap.put("IwScheduledQty","IwScheduledQty");
		intergerMap.put("OutboundType","OutboundType");
		intergerMap.put("OutCode","OutCode");
		intergerMap.put("Qty","Qty");
		intergerMap.put("DeliveryFeeType","DeliveryFeeType");
		intergerMap.put("ReqQty","ReqQty");
		intergerMap.put("WmsOrderNo","WmsOrderNo");
		intergerMap.put("GoodsQty","GoodsQty");
		intergerMap.put("OnedayDeliveryIs","OnedayDeliveryIs");
		intergerMap.put("ShipmentPriority","ShipmentPriority");
		intergerMap.put("GiftPackingType","GiftPackingType");
		intergerMap.put("WmsOrderCartonLine","WmsOrderCartonLine");
		intergerMap.put("SkuQty","SkuQty");
		intergerMap.put("SiteId","SiteId");
		intergerMap.put("SiteOrderNo","SiteOrderNo");
		intergerMap.put("CartNo","CartNo");
		intergerMap.put("DistrCenterType","DistrCenterType");
		intergerMap.put("StorageType","StorageType");
		intergerMap.put("RefundType","RefundType");

		
		
		stringMap = new DataMap();
		//stringMap.put("string", 10);
		
		dateMap = new DataMap();
		dateMap.put("IwScheduledDate", "IwScheduledDate");
		dateMap.put("StartDate","StartDate");
		dateMap.put("EndDate","EndDate");
		dateMap.put("IwScheduledDate","IwScheduledDate");
		dateMap.put("ReqDate","ReqDate");
		dateMap.put("DeliveryWishDate","DeliveryWishDate");
	}
	
	public String checkData(String ifName, DataMap map){
		Set set = null;
		Iterator it = null;
		
		if(emptyMap.containsKey(ifName)){
			DataMap emMap = emptyMap.getMap(ifName);
			set = emMap.keySet();
			it = set.iterator();
			
			while (it.hasNext()) {
				String key = (String)it.next();
				if(map.isEmpty(key)){
					return "Required value ["+key+"] is no ";           
				} // 필수값[]가 없습니다
			}
		}
		
		set = map.keySet();
		it = set.iterator();
		
		while (it.hasNext()) {
			String key = (String)it.next();
			String value = map.getString(key);
			
			if(intergerMap.containsKey(key)){
				/*int len = intergerMap.getInt(key);
				if(value.length() > len){
					return key+" 값의 크기가 초과되었습니다. "+ value;    
				}else*/
				if(!checkNumber(value)){
					return key+" : Not a number. ["+ value+"]";      
				}
			}else if(stringMap.containsKey(key)){
				int len = stringMap.getInt(key);
				if(value.length() > len){
					return key+" : The size of the value has been exceede. ["+ value+"]";    
				}
			}else if(dateMap.containsKey(key)){
				if(!checkDateTime(value)){
					return key+" : Date value is invalid. ["+ value+"]";   
				}
			}
		}
		return null;
	}
	
	public boolean checkNumber(String num){
		try {
			BigDecimal big = new BigDecimal(num);
		} catch (Exception e) {
			return false;
		}
		return true;
	}
	
	public boolean checkInteger(String num){
		try {
			Integer.parseInt(num);
		} catch (Exception e) {
			return false;
		}
		return true;
	}
	
	public boolean checkDate(String num){
		try {
			new GregorianCalendar(Integer.parseInt(num.substring(0,4)), Integer.parseInt(num.substring(4,6))-1, Integer.parseInt(num.substring(6,8)));
		} catch (Exception e) {
			return false;
		}
		return true;
	}
	
	public boolean checkTime(String num){
		try {
			int h = Integer.parseInt(num.substring(0,2));
			if(h<0 || h>24){
				return false;
			}
			int m = Integer.parseInt(num.substring(2,4));
			if(m<0 || m>60){
				return false;
			}
			int s = Integer.parseInt(num.substring(4,6));
			if(s<0 || s>60){
				return false;
			}
		} catch (Exception e) {
			return false;
		}
		return true;
	}
	
	public boolean checkDateTime(String num){
		//“HeaderProcDate”:”2016-10-07T10:10:10”
		try {
			new GregorianCalendar(Integer.parseInt(num.substring(0,4)), Integer.parseInt(num.substring(5,7))-1, Integer.parseInt(num.substring(8,10)));
			int h = Integer.parseInt(num.substring(11,13));
			if(h<0 || h>24){
				return false;
			}
			int m = Integer.parseInt(num.substring(14,16));
			if(m<0 || m>60){
				return false;
			}
			int s = Integer.parseInt(num.substring(17,19));
			if(s<0 || s>60){
				return false;
			}
		} catch (Exception e) {
			return false;
		}
		return true;
	}
	
	public String getTarget(String key){
		//return targetMap.getString(key);
		return restful.getProperty(key);
	}
}