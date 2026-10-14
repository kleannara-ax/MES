using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Configuration;

namespace SmartDas
{
    public enum LogType { PROC, ERROR, WARNING, TEST }

    public static class LogFile
    {
        public static string DefaultDirectory = "C:\\Kleannara";
        public static string FolderName = "Log";
        static string sPreFileName = "";    //이전 파일명

        const double CON_DEL_DAYS = -60;    //오늘기준 60일 넘는 로그 파일은 삭제 한다.

        private static Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        public static void WriteLog(string msg, LogType logType = LogType.ERROR)
        {
            StreamWriter sw = null;
            try
            {
                Console.WriteLine(msg);

                if (!Directory.Exists(DefaultDirectory))
                {
                    Directory.CreateDirectory(DefaultDirectory);
                }

                string sDirPath = DefaultDirectory + "\\" + FolderName + "\\";
                string sFileName = sDirPath + DateTime.Now.ToString("yyyy-MM-dd") + ".txt";

                if (!Directory.Exists(DefaultDirectory + "\\" + FolderName))
                {
                    Directory.CreateDirectory(DefaultDirectory + "\\" + FolderName);
                }

                // 날짜가 변경될때만 삭제할 파일들 검사
                if (sFileName != sPreFileName)
                {
                    sPreFileName = sFileName;
                    fileDelete(sDirPath, DateTime.Now.ToString("yyyy-MM-dd"));
                }

                sw = new StreamWriter(sFileName, true);

                string sMSG = "";

                sMSG += DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff ");

                switch (logType)
                {
                    case LogType.PROC:
                        sMSG += "[PROC] ";
                        break;
                    case LogType.ERROR:
                        sMSG += "[ERROR] ";
                        break;
                    case LogType.WARNING:
                        sMSG += "[WARNING] ";
                        break;
                    case LogType.TEST:
                        sMSG += "[TEST] ";
                        break;
                }

                sw.WriteLine(sMSG + msg);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (sw != null)
                    sw.Close();
            }
        }

        //public static void LogSave(string msg)
        //{
        //    string sDirPath = AppDomain.CurrentDomain.BaseDirectory + @"\LOG\";
        //    string smsg = "", sfullpathfile = sDirPath + DateTime.Now.ToString("yyyy-MM-dd") + ".txt";
        //    string sDelYN = appConfig.AppSettings.Settings["LOGFILEDELETEYN"].Value;

        //    DirectoryInfo di = new DirectoryInfo(sDirPath);
        //    if (di.Exists == false)
        //    {
        //        di.Create();
        //    }

        //    if (sDelYN == "Y")
        //    {
        //        fileDelete(sDirPath, DateTime.Now.ToString("yyyy-MM-dd"));
        //    }

        //    smsg = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + " : " + msg;

        //    FileInfo fInfo = new FileInfo(sfullpathfile);
        //    // 해당 파일이 있으면
        //    if (fInfo.Exists)
        //    {
        //        FileStream fStream = File.Open(sfullpathfile, FileMode.Append);
        //        StreamWriter sw = new StreamWriter(fStream);

        //        sw.WriteLine(smsg);
        //        sw.Close();
        //    }
        //    else
        //    {
        //        FileStream fStream = File.Open(sfullpathfile, FileMode.CreateNew);
        //        StreamWriter sw = new StreamWriter(fStream);

        //        sw.WriteLine(smsg);
        //        sw.Close();
        //    }
        //}

        /// <summary>
        /// 오늘기준 7일치만 저장한다.
        /// </summary>
        private static void fileDelete(string FullPath, string baseDate)
        {
            if (string.IsNullOrEmpty(baseDate))
                return;

            DateTime targetDT = DateTime.Parse(baseDate).AddDays(CON_DEL_DAYS);

            FileInfo targetFile = new FileInfo(FullPath);
            string DirPath = targetFile.DirectoryName;

            List<FileInfo> fileList = FileSearchLT(DirPath, targetDT);

            foreach (FileInfo fi in fileList)
            {
                if (fi.Exists)
                {
                    fi.Delete();
                }
            }
        }

        /// <summary>
		/// 마지막 변경일자를 기준으로 file search
		/// </summary>
		/// <param name="FullPath"></param>
		/// <returns></returns>
        private static List<FileInfo> FileSearchLT(string DirPath, DateTime targerdt)
        {
            var files = from file in new DirectoryInfo(DirPath).GetFiles()
                        where file.LastWriteTime < targerdt
                        orderby file.LastWriteTime
                        select file;
            return files.ToList();
        }

        
    }
}
