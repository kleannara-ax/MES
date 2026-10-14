using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SAMMI
{
    public class SException : System.Exception
    {
        public string ErrorCode     = string.Empty;
        public string ExceptionType = string.Empty;
        public Exception BaseException;

        public SException(string errorcode, Exception ex)
        {
            this.ErrorCode = errorcode;
            this.BaseException = ex;
        }
    }
}
