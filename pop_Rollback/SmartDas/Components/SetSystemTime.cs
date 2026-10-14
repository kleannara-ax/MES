using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SmartDas.Components
{
    /// <summary>
    /// 시스템 시간 변경 클래스
    /// </summary>
    public class SetSystemTimeClass
    {
        /// <summary>
        /// 표준시간ㅔ ( 한국 표준시 : +9 )
        /// </summary>
        public int StandardTimeInterval;

        [System.Runtime.InteropServices.DllImport("kernel32", SetLastError = true)]
        private static extern bool SetSystemTime(ref SYSTEMTIME systemTime); 

        private DateTime _dDate;

        private struct SYSTEMTIME
        {
            public short wYear;
            public short wMonth;
            public short wDayOfWeek;
            public short wDay;
            public short wHour;
            public short wMinute;
            public short wSecond;
            public short wMilliseconds;
        }

        /// <summary>
        /// 시스템시간 변경 클래스
        /// </summary>
        /// <param name="dDateTime">변경할 시간</param>
        public SetSystemTimeClass(DateTime dDateTime)
        {
            _dDate = dDateTime;
            StandardTimeInterval = 0;
        }

        /// <summary>
        /// 시스템 시간 변경
        /// </summary>
        public void SetTime()
        {
            SYSTEMTIME tSys = new SYSTEMTIME();

            tSys.wYear = (short)_dDate.Year;
            tSys.wMonth = (short)_dDate.Month;
            tSys.wDayOfWeek = (short)_dDate.DayOfWeek;
            tSys.wDay = (short)_dDate.Day;
            tSys.wHour = (short)(_dDate.Hour - StandardTimeInterval);
            tSys.wMinute = (short)_dDate.Minute;
            tSys.wSecond = (short)_dDate.Second;
            tSys.wMilliseconds = (short)_dDate.Millisecond;

            SetSystemTime(ref tSys);
        }
    }
}
