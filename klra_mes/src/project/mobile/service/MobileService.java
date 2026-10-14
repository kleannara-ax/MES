package project.mobile.service;

import org.json.JSONObject;
import org.json.XML;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.bean.FileRepository;
import project.common.dao.CommonDAO;
import project.common.util.FileUtil;
import project.mes.dao.IFDAO;
import project.mes.service.WmsService;
import project.mobile.dao.MobileDao;

import javax.imageio.*;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;
import javax.servlet.http.HttpServletRequest;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Service
public class MobileService {

	@Autowired
	public CommonDAO commonDao;
	
	@Autowired
	public MobileDao mobileDao;
	
	@Autowired
	public IFDAO ifDao;
	
	@Autowired
	private FileRepository respository;
	
	public String getDocSeq(String docType) throws SQLException{
		DataMap map = new DataMap("Common", "DOCUSEQ");
		map.put("DOCUTY", docType);
		
		return (String)commonDao.insert(map);
	}
	
	public String getNumSeq(String numObj) throws SQLException{
		DataMap map = new DataMap("Common", "NROBJ");
		map.put("NUMOBJ", numObj);
		
		return (String)commonDao.insert(map);
	}

	@Transactional
	public Object usrname(DataMap map) throws SQLException {
		
		map.setModuleCommand("Mobile", "FINDUSRNAME");
		map.put("USRID", map.get(CommonConfig.SES_USER_ID_KEY));
		DataMap returnMap = commonDao.getMap(map);
		returnMap.put("WAREKY", map.get(CommonConfig.SES_USER_WHAREHOUSE_KEY));
		
		return returnMap;
	}
	
	/**
     * 원본 파일을 리사이징하여 변환할 파일에 저장한다.
     * @param srcFile
     * @param extension
     * @param tarFile
     * @param tarWidth
     * @param tarHeight
     */
    public void resizeFile(File srcFile, String extension, File tarFile, int tarWidth, int tarHeight) throws IOException {
        ImageInputStream  iis = null;
        ImageOutputStream ios = null;
        ImageReader ir = null;
        ImageWriter iw = null;
        try {
            iis = ImageIO.createImageInputStream(srcFile);
            ios = ImageIO.createImageOutputStream(tarFile);
            
            ir = ImageIO.getImageReadersByFormatName(extension).next();
            iw = ImageIO.getImageWritersByFormatName(extension).next();
            ir.setInput(iis);
            iw.setOutput(ios);

            ImageWriteParam iwp = iw.getDefaultWriteParam();
            
            
            // compression 미지원 포맷은 오류가 발생할 수 있다. (png, gif 등)
            try {
                iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                iwp.setCompressionQuality(1);
            } catch(Exception e) {}

            BufferedImage srcBi = ir.read(0);
            int srcWidth  = srcBi.getWidth();
            int srcHeight = srcBi.getHeight();
            double ratio = 0;
            
            // 긴 축을 기준으로 tarWidth와 tarHeight를 다시 구한다.
            if(srcWidth >= srcHeight) {
                ratio = (double)tarWidth / (double)srcWidth;
                tarHeight = (int)(srcHeight * ratio);  
            } else {
                ratio = (double)tarHeight / (double)srcHeight;
                tarWidth = (int)(srcWidth * ratio);  
            }
            
            BufferedImage tarBi = new BufferedImage(tarWidth, tarHeight, BufferedImage.TYPE_INT_RGB);
            Graphics2D g = tarBi.createGraphics();
            g.drawImage(srcBi, 0, 0, tarWidth, tarHeight, null);
            
            IIOImage tarImg = new IIOImage(tarBi, null, null);
            iw.write(null, tarImg, iwp);
        } catch(Exception e) {
            throw e;
        } finally {
            if(iis != null) { iis.close(); }
            if(ios != null) { ios.close(); }
            if(ir  != null) { ir.dispose(); }
            if(iw  != null) { iw.dispose(); }
        }
    }
    
    /**
     * 파일 복사
     * @param srcFile
     * @param tarFile
     * @throws IOException
     */
    public void copyFile(File srcFile, File tarFile) throws IOException {
    	//FileInputStream fis = null;
    	//FileOutputStream fos = null;
    	InputStream is = null;
    	OutputStream os = null;
    	String srcfileName = srcFile.getPath();
    	String tarfileName = tarFile.getPath();
    	
    	try {
    		//fis = new FileInputStream(srcFile);
			//fos = new FileOutputStream(tarFile);
    		is = Files.newInputStream(Paths.get(srcfileName)); 
    		os = Files.newOutputStream(Paths.get(tarfileName));
			int data = 0;
			while((data = is.read()) != -1){
				os.write(data);
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if(is != null) { is.close(); }
			if(os != null) { os.close(); }
		}
    }
    
    //개별바코드별 10초내 중복요청 체크
	public Boolean duplicationCheck(String indBcd) throws SQLException{
		Boolean resultBoolean = true;
		DataMap map = new DataMap("Common", "IND_BCD");
		map.put("IND_BCD", indBcd);

		int result = mobileDao.duplicationCheck(map);
		if(result > 0 ) {
			resultBoolean = false;
		}
		return resultBoolean;
	}

	//지분검사 실적조회
	public List<DataMap> findJumboResultForInspection(DataMap dataMap) throws Exception{
		return mobileDao.selectJumboResultForInspection(dataMap);
	}

	//지분검사 실적 저장
	@Transactional(rollbackFor = Exception.class)
	public int saveDustInspectionResult(DataMap dataMap) throws Exception{
		int hdrInsertRes = 0;
		int dtlInsUpdRes = 0;

		dataMap.put("WERKS", "P100");
		dataMap.put("INSP_ITEM_GRP_CD", "P1"); //PS 점보롤 검사, P1
		dataMap.put("INSP_ITEM_CD", "P1P75"); // P1P75, 후면 껄
		dataMap.put("REGID", "dustInspection");

		DataMap keyInfo = mobileDao.getInspectionKeyInfo(dataMap);

		try {
			if (keyInfo != null) {
				dataMap.put("NEW_MSRM_DATE", keyInfo.get("NEW_MSRM_DATE"));
				dataMap.put("OLD_MSRM_DATE", keyInfo.get("OLD_MSRM_DATE"));
				dataMap.put("PRC_SEQNO", keyInfo.get("PRC_SEQNO"));
				dataMap.put("MATNR", keyInfo.get("MATNR"));
			}

			mobileDao.updateDefectMsrmDate(dataMap);	//TB_QLT024
			mobileDao.updateInvMsrmDate(dataMap);		//TB_INV001

			String oldMsrmDate = dataMap.getString("OLD_MSRM_DATE");
			if (oldMsrmDate != null && !"".equals(oldMsrmDate)) {
				mobileDao.updateDetailMsrmDate(dataMap);	//TB_QLT021
			}

			hdrInsertRes = mobileDao.updateInspectionHeader(dataMap); //TB_QLT020

			if(hdrInsertRes > 0) {
				dtlInsUpdRes = mobileDao.updateDustInspectionResult(dataMap); //TB_QLT021
			}

		} catch (Exception ex) {
			System.err.println("=== saveDustInspectionResult 서비스 에러 발생 ===");
			System.err.println("에러 원인: " + ex.getMessage());
			ex.printStackTrace(); // 콘솔에 상세한 톰캣 에러 라인 전부 출력

			throw ex;
		}

		return dtlInsUpdRes;
	}
}