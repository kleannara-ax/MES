using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SmartDas.POPUP
{
    public partial class CircularProgressControl : UserControl
    {
        #region Constants

        private const int      DEFAULT_INTERVAL     = 60;
        private readonly Color DEFAULT_TICK_COLOR   = Color.FromArgb(58, 58, 58);
        private const int      DEFAULT_TICK_WIDTH   = 2;
        private const int      MINIMUM_INNER_RADIUS = 4;
        private const int      MINIMUM_OUTER_RADIUS = 8;
        private Size           MINIMUM_CONTROL_SIZE = new Size(28, 28);
        private const int      MINIMUpen_WIDTH    = 2;
        private const float    INNER_RADIUS_FACTOR  = 0.40F;
        private const float    OUTER_RADIUS_FACTOR  = 0.45F;
        private const int      DEFAULT_SPOKES_COUNT = 12;

        #endregion

        #region Enums

        public enum Direction
        {
            CLOCKWISE,
            ANTICLOCKWISE
        }

        public enum ControlType
        {
            PROGRESS,
            PERCENT
        }

        public enum MessagePositionType
        {
            Top,
            Bottom,
            Left,
            Right
        }
        #endregion

        #region Structs

        struct Spoke
        {
            public PointF StartPoint;
            public PointF EndPoint;

            public Spoke(PointF pt1, PointF pt2)
            {
                StartPoint = pt1;
                EndPoint = pt2;
            }
        }

        #endregion

        #region Members
        private int                 interval;
        private int                 spokeThick         = 0;
        private double              timeThick          = 0.0;
        private float               innerRadiousFactor = 0.0F;
        private float               outerRadiousFactor = 0.5F;
        private Pen                 pen              = null;
        private PointF              centerPt         = new PointF();
        private int                 innerRadius      = 0;
        private int                 outerRadius      = 0;
        private int                 spokeCount       = 12;
        private int                 alphaChange      = 0;
        private int                 alphaLowerLimit  = 0;
        private float               startAngle       = 0;
        private float               angleIncrement   = 0;
        private Direction           rotation;        
        private System.Timers.Timer timer            = null;
        private List<Spoke>         spokes           = null;
        private bool                showTime           = true;
        private bool                isshowMessage      = true;
        private double              percent            = 0.0;
        private ControlType         controlType        = ControlType.PROGRESS;
        private MessagePositionType messagePositionType = MessagePositionType.Bottom;
        private string              centerMessage      = string.Empty;
        private string              message            = string.Empty;
        private RectangleF          centerMessageRect;
        private RectangleF          messageRect;
        #endregion

        #region Properties
        public MessagePositionType MessagePosition
        {
            get
            {
                return this.messagePositionType;
            }
            set
            {
                this.messagePositionType = value;
                this.CalculatePosition();
                this.Invalidate();
            }
        }
        /// <summary>
        /// Time interval for each tick.
        /// </summary>
        public int Interval
        {
            get
            {
                return interval;
            }
            set
            {
                if (value > 0)
                {
                    interval = value;
                }
                else
                {
                    interval = DEFAULT_INTERVAL;
                }
            }
        }

        /// <summary>
        /// Color of the tick
        /// </summary>
        public Color TickColor { get; set; }

        /// <summary>
        /// Direction of rotation - CLOCKWISE/ANTICLOCKWISE
        /// </summary>
        public Direction Rotation
        {
            get
            {
                return rotation;
            }
            set
            {
                rotation = value;
                CalculatePosition();
            }
        }

        /// <summary>
        /// Angle at which the tick should start
        /// </summary>
        public float StartAngle
        {
            get
            {
                return startAngle;
            }
            set
            {
                startAngle = value;
            }
        }

        /// <summary>
        /// CircularProgressControl의 바 갯수
        /// </summary>
        public int SpokesCount
        {
            get
            {
                return spokeCount;
            }
            set
            {
            	spokeCount = value;
                CalculatePosition();
                Invalidate();
            }

        }

        /// <summary>
        /// Spoke의 갯수
        /// </summary>
        public int SpokeThick
        {
            get
            {
                return this.spokeThick;
            }
            set
            {
                spokeThick = value;
                this.CalculatePosition();
                Invalidate();
            }
        }

        public String CenterMessage
        {
            get
            {
                return this.centerMessage;
            }
            set
            {
                this.centerMessage = value;
                Invalidate();
            }
        }

        public String Message
        {
            get
            {
                return this.message;
            }
            set
            {
                this.message = value;
                Invalidate();
            }
        }

        public float InnerRadiousFactor
        {
            get
            {
                return this.innerRadiousFactor * 2;
            }
            set
            {
                this.innerRadiousFactor = value / 2F;
                this.CalculatePosition();
                Invalidate();
            }
        }

        public float OuterRadiousFactor
        {
            get
            {
                return this.outerRadiousFactor * 2;
            }
            set
            {
                this.outerRadiousFactor = value / 2F;
                this.CalculatePosition();
                Invalidate();
            }
        }

        public bool ShowTime
        {
            get
            {
                return this.showTime;
            }
            set
            {
                this.showTime = value;
            }
        }

        public bool IsShowMessage
        {
            get
            {
                return this.isshowMessage;
            }
            set
            {
                this.isshowMessage = value;
                //this.lblMessage.Visible = value;

                CalculatePosition();

                Invalidate();
            }
        }


        public Double Percent
        {
            get
            {
                return this.percent;
            }
            set
            {
                this.percent = value;
                this.SetText(this.percent.ToString("##0") + "%");
                Invalidate();
            }
        }

        public ControlType Type
        {
            get
            {
                return this.controlType;
            }
            set
            {
                this.controlType = value;
                Invalidate();
            }
        }
        #endregion

        #region Construction/Initialization

        /// <summary>
        /// Ctor
        /// </summary>
        public CircularProgressControl()
        {
            this.DoubleBuffered = true;

            InitializeComponent();

            this.DoubleBuffered = true;

            // Set Default Values
            this.BackColor    = Color.Transparent;
            this.TickColor    = DEFAULT_TICK_COLOR;
            this.MinimumSize  = MINIMUM_CONTROL_SIZE;
            this.Interval     = DEFAULT_INTERVAL;
            // Default starting angle is 12 o'clock
            this.StartAngle   = 270;
            // Default number of Spokes in this control is 12
            spokeCount     = DEFAULT_SPOKES_COUNT;
            // Set the Lower limit of the Alpha value (The spokes will be shown in 
            // alpha values ranging from 255 to alphaLowerLimit)
            alphaLowerLimit = 15;

            // Create the Pen
            pen = new Pen(TickColor, DEFAULT_TICK_WIDTH);
            pen.EndCap = System.Drawing.Drawing2D.LineCap.Round;
            pen.StartCap = System.Drawing.Drawing2D.LineCap.Round;

            // Default rotation direction is clockwise
            this.Rotation = Direction.CLOCKWISE;

            // Calculate the Spoke Points
            CalculatePosition();

            timer = new System.Timers.Timer(this.Interval);
            timer.Elapsed += new System.Timers.ElapsedEventHandler(OnTimerElapsed);
        }

        /// <summary>
        /// Calculate the Spoke Points and store them
        /// </summary>
        private void CalculatePosition()
        {
            int width = this.CalculateMessagePoint();;
            
            spokes = new List<Spoke>();

            // Calculate the angle between adjacent spokes
            angleIncrement = (360 / (float)spokeCount);
            // Calculate the change in alpha between adjacent spokes
            alphaChange = (int)((255 - alphaLowerLimit) / spokeCount);
          
            // Calculate the width of the pen which will be used to draw the spokes
            if (this.spokeThick == 0)
            {
                pen.Width = (int)(width / 15);
                if (pen.Width < MINIMUpen_WIDTH)
                    pen.Width = MINIMUpen_WIDTH;
            }
            else
                pen.Width = this.spokeThick;

            // Calculate the inner and outer radii of the control. The radii should not be less than the
            // Minimum values
            innerRadius = (int)(width * this.innerRadiousFactor);
            if (innerRadius < MINIMUM_INNER_RADIUS)
                innerRadius = MINIMUM_INNER_RADIUS;
            outerRadius = (int)(width * this.outerRadiousFactor);
            if (outerRadius < MINIMUM_OUTER_RADIUS)
                outerRadius = MINIMUM_OUTER_RADIUS;

            float angle = 0;

            for (int i = 0; i < spokeCount; i++)
            {
                PointF pt1 = new PointF(innerRadius * (float)Math.Cos(ConvertDegreesToRadians(angle)), innerRadius * (float)Math.Sin(ConvertDegreesToRadians(angle)));
                PointF pt2 = new PointF(outerRadius * (float)Math.Cos(ConvertDegreesToRadians(angle)), outerRadius * (float)Math.Sin(ConvertDegreesToRadians(angle)));

                // Create a spoke based on the points generated
                Spoke spoke = new Spoke(pt1, pt2);
                // Add the spoke to the List
                spokes.Add(spoke);

                if (Rotation == Direction.CLOCKWISE)
                {
                    angle -= angleIncrement;
                }
                else if (Rotation == Direction.ANTICLOCKWISE)
                {
                    angle += angleIncrement;
                }
            }
        }

        private int CalculateMessagePoint()
        {
            System.Drawing.Graphics curgraphics = this.CreateGraphics();
            int width = 0;

            if (!isshowMessage)
            {
                centerMessageRect = new RectangleF(0
                                                  ,this.Height / 2 - (this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.1F)/2F
                                                  ,this.Width, this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.1F) ;
                width = (this.Width < this.Height) ? this.Width : this.Height;
                centerPt = new PointF(this.Width / 2, this.Height / 2);

                return width;
            }

            int centermessageheight = 0;
            int centermessagewidth  = 0;
            int messageheight       = 0;
            int centermessageX      = 0;
            int centermessageY      = 0;
            int messagewidth        = 0;
            int messageX            = 0;
            int messageY            = 0;

            switch (this.messagePositionType)
            {
                case MessagePositionType.Top:
                     width               = (this.Width < (this.Height - messageRect.Height)) ? this.Width : Convert.ToInt16(this.Height - messageRect.Height);
                     centermessagewidth  = this.Width;
                     centermessageheight = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.2F);
                     messagewidth        = this.Width;
                     messageheight       = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 2F);
                     centermessageX      = 0;
                     centermessageY      = (this.Height + messageheight - centermessageheight) / 2;
                     messageX            = 0;
                     messageY            = 0;
                     centerPt            = new PointF(this.Width / 2, (this.Height + messageheight) / 2);                    
                     break;
                case MessagePositionType.Bottom:
                     width               = (this.Width < (this.Height - messageRect.Height)) ? this.Width : Convert.ToInt16(this.Height - messageRect.Height);
                     centermessagewidth  = this.Width;
                     centermessageheight = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.2F);
                     messagewidth        = this.Width;
                     messageheight       = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 2F);
                     centermessageX      = 0;
                     centermessageY      = (this.Height - messageheight - centermessageheight) / 2;
                     messageX            = 0;
                     messageY            = this.Height - messageheight;
                     centerPt            = new PointF(this.Width / 2, (this.Height - messageheight) / 2);
                     break;
                case MessagePositionType.Left:
                     width               = (this.Width < this.Height) ? this.Width : this.Height;
                     centermessageheight = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.2F);
                     centermessagewidth  = width;
                     messagewidth        = this.Width - width < 0 ? 0 : this.Width - width;
                     messageheight       = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.2F);
                     centermessageX      = messagewidth;
                     centermessageY      = (this.Height - centermessageheight) / 2;
                     messageX            = 0;
                     messageY            = (this.Height - messageheight) / 2;
                     centerPt            = new PointF(messagewidth + (width) / 2, this.Height / 2);
                     break;
                case MessagePositionType.Right:
                     width               = (this.Width < this.Height) ? this.Width : this.Height;
                     centermessageheight = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.2F);
                     centermessagewidth  = width;
                     messagewidth        = this.Width - width < 0 ? 0 : this.Width - width;
                     messageheight       = Convert.ToInt16(this.Font.SizeInPoints *  curgraphics.DpiY / 72 * 1.2F);
                     centermessageX      = 0;
                     centermessageY      = (this.Height - centermessageheight) / 2;
                     messageX            = width;
                     messageY            = (this.Height - messageheight) / 2;
                     centerPt            = new PointF(width / 2, this.Height / 2);
                     break;
            }

            messageRect       = new RectangleF(messageX,       messageY,       messagewidth,       messageheight);
            centerMessageRect = new RectangleF(centermessageX, centermessageY, centermessagewidth, centermessageheight);

            return width;
        }

        #endregion

        #region EventHandlers

        /// <summary>
        /// Handler for the event when the size of the control changes
        /// </summary>
        /// <param name="e">EventArgs</param>
        protected override void OnClientSizeChanged(EventArgs e)
        {
            CalculatePosition();
        }

        /// <summary>
        /// Handle the Tick event
        /// </summary>
        /// <param name="sender">Timer</param>
        /// <param name="e">ElapsedEventArgs</param>
        void OnTimerElapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            if (Rotation == Direction.CLOCKWISE)
            {
                startAngle += angleIncrement;

                if (startAngle >= 360)
                    startAngle = 0;
            }
            else if (Rotation == Direction.ANTICLOCKWISE)
            {
                startAngle -= angleIncrement;

                if (startAngle <= -360)
                    startAngle = 0;
            }

            if (this.showTime)
            {
                timeThick = timeThick + this.Interval / 1000.0;
                this.SetText(timeThick.ToString("#,##0.0"));
            }
            else
            {
                this.SetText(this.centerMessage + "\r\n" + "( " +timeThick.ToString("#,##0.0") + " )"); 
            };
            Invalidate();
        }


        /// <summary>
        /// Handles the Paint Event of the control
        /// </summary>
        /// <param name="e">PaintEventArgs</param>
        protected override void OnPaint(PaintEventArgs e)
        {
            StringFormat centerMessageFormat = new StringFormat();
            StringFormat messageformat = new StringFormat(StringFormatFlags.MeasureTrailingSpaces);
            SolidBrush brush = new SolidBrush(this.ForeColor);

            centerMessageFormat.Alignment = StringAlignment.Center;
            centerMessageFormat.LineAlignment = StringAlignment.Center;
            messageformat.LineAlignment = StringAlignment.Center;
            switch (this.MessagePosition)
            {
                    case MessagePositionType.Bottom:
                    case MessagePositionType.Top:
                         messageformat.Alignment = StringAlignment.Center;
                         break;
                    case MessagePositionType.Right:
                         messageformat.Alignment = StringAlignment.Near;
                         break;
                    case MessagePositionType.Left:    
                         messageformat.Alignment = StringAlignment.Far;
                         break;
            }
            
            e.Graphics.DrawString(this.CenterMessage, this.Font, brush, this.centerMessageRect, centerMessageFormat);
            if (this.isshowMessage)
                e.Graphics.DrawString(this.message, this.Font, brush, this.messageRect, messageformat);            
            
            e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            e.Graphics.SmoothingMode     = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            
            e.Graphics.TranslateTransform(centerPt.X, centerPt.Y, System.Drawing.Drawing2D.MatrixOrder.Prepend);
            e.Graphics.RotateTransform(startAngle, System.Drawing.Drawing2D.MatrixOrder.Prepend);

            int alpha = 255;

            // Render the spokes
            for (int i = 0; i < spokeCount; i++)
            {
                pen.Color = Color.FromArgb(alpha, this.TickColor);
                e.Graphics.DrawLine(pen, spokes[i].StartPoint, spokes[i].EndPoint);

                if (this.controlType == ControlType.PROGRESS)
                {
                    alpha -= alphaChange;
                    if (alpha < alphaLowerLimit)
                        alpha = 255 - alphaChange;

                }
                else
                {
                    if ((double)i/(double)spokeCount * 100 < this.percent )
                    {
                        alpha = 255;
                    }
                    else
                    {
                        alpha = 0;
                    }
                }
            }

            // Perform a reverse Rotation and Translation to obtain the original Transformation
            e.Graphics.RotateTransform(-startAngle, System.Drawing.Drawing2D.MatrixOrder.Append);
            e.Graphics.TranslateTransform(-centerPt.X, -centerPt.Y, System.Drawing.Drawing2D.MatrixOrder.Append);
        }
        #endregion

        #region Helpers

        /// <summary>
        /// Converts Degrees to Radians
        /// </summary>
        /// <param name="degrees">Degrees</param>
        /// <returns></returns>
        private double ConvertDegreesToRadians(float degrees)
        {
            return ((Math.PI / (double)180) * degrees);
        }

        public void SetText(string text)
        {
            this.CenterMessage = text;
        }

        public void SetMessage(string text)
        {
            this.Message = text;
        }
        #endregion

        #region APIs

        /// <summary>
        /// Start the Tick Control rotation
        /// </summary>
        public void Start()
        {
            if (this.controlType == ControlType.PERCENT) return;

            if (timer != null)
            {
                this.timeThick = 0.0;
                timer.Interval = this.Interval;
                timer.Enabled = true;
            }
        }

        /// <summary>
        /// Stop the Tick Control rotation
        /// </summary>
        public void Stop()
        {
            if (timer != null)
            {
                timer.Enabled = false;
            }
        }

        #endregion
    }
}

