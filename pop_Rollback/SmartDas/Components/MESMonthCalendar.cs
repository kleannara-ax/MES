using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class MESMonthCalendar : MonthCalendar
{
    [DllImport("uxtheme.dll", ExactSpelling = true, CharSet = CharSet.Unicode)]
    static extern int SetWindowTheme(IntPtr hwnd, string pszSubAppName, string pszSubIdList);
    protected override void OnHandleCreated(EventArgs e)
    {
        SetWindowTheme(Handle, string.Empty, string.Empty);
        base.OnHandleCreated(e);
    }

    public event EventHandler DoubleClickEx;

    string sDataDateChanged = "";
    string sDataMouseDown = "";

    public MESMonthCalendar()
    {
        lastClickTick = Environment.TickCount - SystemInformation.DoubleClickTime;
    }

    protected override void OnMouseDown(MouseEventArgs e) {

        int tick = Environment.TickCount;

        if (sDataMouseDown.Equals(sDataDateChanged))
        {
            if (tick - lastClickTick <= SystemInformation.DoubleClickTime)
            {
                EventHandler handler = DoubleClickEx;
                if (handler != null) handler(this, EventArgs.Empty);
            }
            else
            {
                base.OnMouseDown(e);
                lastClickTick = tick;
            }
        }
        else
        {
            base.OnMouseDown(e);
            lastClickTick = tick;
            sDataMouseDown = sDataDateChanged;
        }
    }

    protected override void OnDateChanged(DateRangeEventArgs drevent)
    {
        sDataDateChanged = drevent.Start.ToShortDateString();
        base.OnDateChanged(drevent);
    }


    private int lastClickTick;


}