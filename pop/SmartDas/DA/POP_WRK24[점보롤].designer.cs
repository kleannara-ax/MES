using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK24
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblWO_PCODE = new SmartDas.Components.MESLabel();
            this.label22 = new System.Windows.Forms.Label();
            this.lblNonOrderBS_WGT = new SmartDas.Components.MESLabel();
            this.lblWO_TSPEED = new SmartDas.Components.MESLabel();
            this.lblWO_WRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.txtWO_ORDER_RMK = new System.Windows.Forms.TextBox();
            this.lblPF_PRFM_DT = new SmartDas.Components.MESLabel();
            this.btnNonOrder = new SmartDas.Components.MESButton();
            this.butEndDate = new System.Windows.Forms.Button();
            this.butStartDate = new System.Windows.Forms.Button();
            this.label12 = new System.Windows.Forms.Label();
            this.dtpEndDate = new MESDateTimePicker();
            this.lblMACH_STA = new System.Windows.Forms.Label();
            this.label26 = new System.Windows.Forms.Label();
            this.lblNonOrderCode = new SmartDas.Components.MESLabel();
            this.label27 = new System.Windows.Forms.Label();
            this.lblNonOrderName = new SmartDas.Components.MESLabel();
            this.label24 = new System.Windows.Forms.Label();
            this.label11 = new System.Windows.Forms.Label();
            this.btnDetail = new SmartDas.Components.MESButton();
            this.lblPrintChkName = new System.Windows.Forms.Label();
            this.lblPrintChk = new SmartDas.Components.MESLabel();
            this.lblEndChkName = new System.Windows.Forms.Label();
            this.lblEndChk = new SmartDas.Components.MESLabel();
            this.dtpStartDate = new MESDateTimePicker();
            this.label21 = new System.Windows.Forms.Label();
            this.lblPF_RSPEED = new SmartDas.Components.MESLabel();
            this.label20 = new System.Windows.Forms.Label();
            this.lblPF_ROLLCNT = new SmartDas.Components.MESLabel();
            this.lblPF_WGT = new SmartDas.Components.MESLabel();
            this.lblPF_TM = new SmartDas.Components.MESLabel();
            this.lblEndTime = new SmartDas.Components.MESLabel();
            this.lblWO_JWIDTH = new SmartDas.Components.MESLabel();
            this.label17 = new System.Windows.Forms.Label();
            this.lblPF_WRK_ORDR_RMK = new SmartDas.Components.MESLabel();
            this.label18 = new System.Windows.Forms.Label();
            this.lblPF_MWIDTH = new SmartDas.Components.MESLabel();
            this.label15 = new System.Windows.Forms.Label();
            this.label16 = new System.Windows.Forms.Label();
            this.label13 = new System.Windows.Forms.Label();
            this.label14 = new System.Windows.Forms.Label();
            this.lblStartTime = new SmartDas.Components.MESLabel();
            this.label9 = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.lblWO_DISPO_QTY = new SmartDas.Components.MESLabel();
            this.label7 = new System.Windows.Forms.Label();
            this.lblWO_TOT_WGT = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.lblWO_PRFM_WGT = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblWO_JROLLCNT = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.lblWO_PRFM_ROLLCNT = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.lblWO_MATNR = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblWO_BS_WGT = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.lblWO_WRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblWO_PRD_REQ_DT = new SmartDas.Components.MESLabel();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(1, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.lblPrintChk);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_PCODE);
            this.splitContainer1.Panel1.Controls.Add(this.label22);
            this.splitContainer1.Panel1.Controls.Add(this.lblNonOrderBS_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_TSPEED);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_WRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.txtWO_ORDER_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_PRFM_DT);
            this.splitContainer1.Panel1.Controls.Add(this.btnNonOrder);
            this.splitContainer1.Panel1.Controls.Add(this.butEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.dtpEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblMACH_STA);
            this.splitContainer1.Panel1.Controls.Add(this.label26);
            this.splitContainer1.Panel1.Controls.Add(this.lblNonOrderCode);
            this.splitContainer1.Panel1.Controls.Add(this.label27);
            this.splitContainer1.Panel1.Controls.Add(this.lblNonOrderName);
            this.splitContainer1.Panel1.Controls.Add(this.label24);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.btnDetail);
            this.splitContainer1.Panel1.Controls.Add(this.lblPrintChkName);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndChkName);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndChk);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.label21);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_RSPEED);
            this.splitContainer1.Panel1.Controls.Add(this.label20);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_ROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_TM);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndTime);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_JWIDTH);
            this.splitContainer1.Panel1.Controls.Add(this.label17);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_WRK_ORDR_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.label18);
            this.splitContainer1.Panel1.Controls.Add(this.lblPF_MWIDTH);
            this.splitContainer1.Panel1.Controls.Add(this.label15);
            this.splitContainer1.Panel1.Controls.Add(this.label16);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTime);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_DISPO_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_TOT_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_PRFM_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_JROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_PRFM_ROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_MATNR);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_BS_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_WRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblWO_PRD_REQ_DT);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 152;
            // 
            // lblWO_PCODE
            // 
            this.lblWO_PCODE.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_PCODE.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_PCODE.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_PCODE.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_PCODE.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_PCODE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_PCODE.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWO_PCODE.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_PCODE.Location = new System.Drawing.Point(808, 112);
            this.lblWO_PCODE.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_PCODE.MoveControl = null;
            this.lblWO_PCODE.Name = "lblWO_PCODE";
            this.lblWO_PCODE.Size = new System.Drawing.Size(150, 50);
            this.lblWO_PCODE.TabIndex = 226;
            this.lblWO_PCODE.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWO_PCODE.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label22
            // 
            this.label22.BackColor = System.Drawing.Color.Gray;
            this.label22.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label22.ForeColor = System.Drawing.Color.White;
            this.label22.Location = new System.Drawing.Point(608, 696);
            this.label22.Name = "label22";
            this.label22.Size = new System.Drawing.Size(165, 42);
            this.label22.TabIndex = 224;
            this.label22.Text = "비계획평량";
            this.label22.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblNonOrderBS_WGT
            // 
            this.lblNonOrderBS_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblNonOrderBS_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblNonOrderBS_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblNonOrderBS_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblNonOrderBS_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblNonOrderBS_WGT.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblNonOrderBS_WGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblNonOrderBS_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblNonOrderBS_WGT.Location = new System.Drawing.Point(780, 696);
            this.lblNonOrderBS_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblNonOrderBS_WGT.MoveControl = null;
            this.lblNonOrderBS_WGT.Name = "lblNonOrderBS_WGT";
            this.lblNonOrderBS_WGT.Size = new System.Drawing.Size(150, 42);
            this.lblNonOrderBS_WGT.TabIndex = 225;
            this.lblNonOrderBS_WGT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblNonOrderBS_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWO_TSPEED
            // 
            this.lblWO_TSPEED.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_TSPEED.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_TSPEED.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_TSPEED.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_TSPEED.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_TSPEED.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_TSPEED.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWO_TSPEED.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_TSPEED.Location = new System.Drawing.Point(178, 271);
            this.lblWO_TSPEED.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_TSPEED.MoveControl = null;
            this.lblWO_TSPEED.Name = "lblWO_TSPEED";
            this.lblWO_TSPEED.Size = new System.Drawing.Size(225, 50);
            this.lblWO_TSPEED.TabIndex = 223;
            this.lblWO_TSPEED.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWO_TSPEED.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWO_WRK_ORDR_SEQNO
            // 
            this.lblWO_WRK_ORDR_SEQNO.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_WRK_ORDR_SEQNO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_WRK_ORDR_SEQNO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_WRK_ORDR_SEQNO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_WRK_ORDR_SEQNO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_WRK_ORDR_SEQNO.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_WRK_ORDR_SEQNO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWO_WRK_ORDR_SEQNO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_WRK_ORDR_SEQNO.Location = new System.Drawing.Point(528, 59);
            this.lblWO_WRK_ORDR_SEQNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_WRK_ORDR_SEQNO.MoveControl = null;
            this.lblWO_WRK_ORDR_SEQNO.Name = "lblWO_WRK_ORDR_SEQNO";
            this.lblWO_WRK_ORDR_SEQNO.Size = new System.Drawing.Size(100, 50);
            this.lblWO_WRK_ORDR_SEQNO.TabIndex = 222;
            this.lblWO_WRK_ORDR_SEQNO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWO_WRK_ORDR_SEQNO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // txtWO_ORDER_RMK
            // 
            this.txtWO_ORDER_RMK.BackColor = System.Drawing.SystemColors.Info;
            this.txtWO_ORDER_RMK.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtWO_ORDER_RMK.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWO_ORDER_RMK.Location = new System.Drawing.Point(8, 326);
            this.txtWO_ORDER_RMK.Multiline = true;
            this.txtWO_ORDER_RMK.Name = "txtWO_ORDER_RMK";
            this.txtWO_ORDER_RMK.ReadOnly = true;
            this.txtWO_ORDER_RMK.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtWO_ORDER_RMK.Size = new System.Drawing.Size(830, 100);
            this.txtWO_ORDER_RMK.TabIndex = 221;
            // 
            // lblPF_PRFM_DT
            // 
            this.lblPF_PRFM_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblPF_PRFM_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_PRFM_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_PRFM_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPF_PRFM_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_PRFM_DT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_PRFM_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_PRFM_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_PRFM_DT.Location = new System.Drawing.Point(1016, 480);
            this.lblPF_PRFM_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_PRFM_DT.MoveControl = null;
            this.lblPF_PRFM_DT.Name = "lblPF_PRFM_DT";
            this.lblPF_PRFM_DT.Size = new System.Drawing.Size(240, 50);
            this.lblPF_PRFM_DT.TabIndex = 220;
            this.lblPF_PRFM_DT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPF_PRFM_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // btnNonOrder
            // 
            this.btnNonOrder.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnNonOrder.BackColor = System.Drawing.Color.Transparent;
            this.btnNonOrder.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnNonOrder.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnNonOrder.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Change;
            this.btnNonOrder.ButtonPressed = false;
            this.btnNonOrder.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnNonOrder.DownPic = null;
            this.btnNonOrder.ExTag = null;
            this.btnNonOrder.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnNonOrder.FontSize = 14F;
            this.btnNonOrder.LinkButtonBox = null;
            this.btnNonOrder.LinkDatePicker = null;
            this.btnNonOrder.LinkGrid = null;
            this.btnNonOrder.LinkMoveSize = 0;
            this.btnNonOrder.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnNonOrder.Location = new System.Drawing.Point(436, 696);
            this.btnNonOrder.Margin = new System.Windows.Forms.Padding(0);
            this.btnNonOrder.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnNonOrder.Name = "btnNonOrder";
            this.btnNonOrder.ParentBox = null;
            this.btnNonOrder.Size = new System.Drawing.Size(165, 42);
            this.btnNonOrder.TabIndex = 215;
            this.btnNonOrder.Text = "비계획생산";
            this.btnNonOrder.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnNonOrder.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnNonOrder.UpPic = null;
            this.btnNonOrder.UseFlag = true;
            this.btnNonOrder.Click += new System.EventHandler(this.btnNonOrder_Click);
            // 
            // butEndDate
            // 
            this.butEndDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butEndDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butEndDate.CausesValidation = false;
            this.butEndDate.FlatAppearance.BorderSize = 0;
            this.butEndDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butEndDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butEndDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butEndDate.Location = new System.Drawing.Point(666, 483);
            this.butEndDate.Name = "butEndDate";
            this.butEndDate.Size = new System.Drawing.Size(46, 46);
            this.butEndDate.TabIndex = 219;
            this.butEndDate.UseVisualStyleBackColor = false;
            this.butEndDate.Click += new System.EventHandler(this.butEndDate_Click);
            // 
            // butStartDate
            // 
            this.butStartDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butStartDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butStartDate.CausesValidation = false;
            this.butStartDate.FlatAppearance.BorderSize = 0;
            this.butStartDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butStartDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butStartDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDate.Location = new System.Drawing.Point(314, 483);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(46, 46);
            this.butStartDate.TabIndex = 35;
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.butStartDate_Click);
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.Location = new System.Drawing.Point(493, 493);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(25, 25);
            this.label12.TabIndex = 218;
            this.label12.Text = "~";
            // 
            // dtpEndDate
            // 
            this.dtpEndDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpEndDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpEndDate.Location = new System.Drawing.Point(529, 480);
            this.dtpEndDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpEndDate.Name = "dtpEndDate";
            this.dtpEndDate.ShowUpDown = true;
            this.dtpEndDate.Size = new System.Drawing.Size(185, 50);
            this.dtpEndDate.TabIndex = 217;
            this.dtpEndDate.ValueChanged += new System.EventHandler(this.dtpDate_ValueChanged);
            this.dtpEndDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // lblMACH_STA
            // 
            this.lblMACH_STA.BackColor = System.Drawing.Color.Black;
            this.lblMACH_STA.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMACH_STA.ForeColor = System.Drawing.Color.Lime;
            this.lblMACH_STA.Location = new System.Drawing.Point(846, 324);
            this.lblMACH_STA.Name = "lblMACH_STA";
            this.lblMACH_STA.Size = new System.Drawing.Size(410, 150);
            this.lblMACH_STA.TabIndex = 216;
            this.lblMACH_STA.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label26
            // 
            this.label26.BackColor = System.Drawing.Color.Gray;
            this.label26.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label26.ForeColor = System.Drawing.Color.White;
            this.label26.Location = new System.Drawing.Point(6, 744);
            this.label26.Name = "label26";
            this.label26.Size = new System.Drawing.Size(165, 42);
            this.label26.TabIndex = 211;
            this.label26.Text = "비계획자재코드";
            this.label26.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblNonOrderCode
            // 
            this.lblNonOrderCode.BackColor = System.Drawing.Color.LightGray;
            this.lblNonOrderCode.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblNonOrderCode.ColorContent = System.Drawing.Color.Transparent;
            this.lblNonOrderCode.ColorLabel = System.Drawing.Color.LightGray;
            this.lblNonOrderCode.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblNonOrderCode.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblNonOrderCode.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblNonOrderCode.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblNonOrderCode.Location = new System.Drawing.Point(178, 744);
            this.lblNonOrderCode.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblNonOrderCode.MoveControl = null;
            this.lblNonOrderCode.Name = "lblNonOrderCode";
            this.lblNonOrderCode.Size = new System.Drawing.Size(250, 42);
            this.lblNonOrderCode.TabIndex = 212;
            this.lblNonOrderCode.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblNonOrderCode.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label27
            // 
            this.label27.BackColor = System.Drawing.Color.Gray;
            this.label27.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label27.ForeColor = System.Drawing.Color.White;
            this.label27.Location = new System.Drawing.Point(436, 744);
            this.label27.Name = "label27";
            this.label27.Size = new System.Drawing.Size(165, 42);
            this.label27.TabIndex = 213;
            this.label27.Text = "비계획자재명";
            this.label27.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblNonOrderName
            // 
            this.lblNonOrderName.BackColor = System.Drawing.Color.LightGray;
            this.lblNonOrderName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblNonOrderName.ColorContent = System.Drawing.Color.Transparent;
            this.lblNonOrderName.ColorLabel = System.Drawing.Color.LightGray;
            this.lblNonOrderName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblNonOrderName.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblNonOrderName.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblNonOrderName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblNonOrderName.Location = new System.Drawing.Point(608, 744);
            this.lblNonOrderName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblNonOrderName.MoveControl = null;
            this.lblNonOrderName.Name = "lblNonOrderName";
            this.lblNonOrderName.Size = new System.Drawing.Size(650, 42);
            this.lblNonOrderName.TabIndex = 214;
            this.lblNonOrderName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblNonOrderName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label24
            // 
            this.label24.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label24.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label24.ForeColor = System.Drawing.Color.Black;
            this.label24.Location = new System.Drawing.Point(6, 430);
            this.label24.Name = "label24";
            this.label24.Size = new System.Drawing.Size(830, 45);
            this.label24.TabIndex = 208;
            this.label24.Text = "실적정보";
            this.label24.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.Black;
            this.label11.Location = new System.Drawing.Point(6, 8);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(1250, 45);
            this.label11.TabIndex = 207;
            this.label11.Text = "생산지시정보";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // btnDetail
            // 
            this.btnDetail.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnDetail.BackColor = System.Drawing.Color.Transparent;
            this.btnDetail.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnDetail.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnDetail.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnDetail.ButtonPressed = false;
            this.btnDetail.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnDetail.DownPic = null;
            this.btnDetail.ExTag = null;
            this.btnDetail.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnDetail.FontSize = 14F;
            this.btnDetail.LinkButtonBox = null;
            this.btnDetail.LinkDatePicker = null;
            this.btnDetail.LinkGrid = null;
            this.btnDetail.LinkMoveSize = 0;
            this.btnDetail.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnDetail.Location = new System.Drawing.Point(428, 271);
            this.btnDetail.Margin = new System.Windows.Forms.Padding(0);
            this.btnDetail.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnDetail.Name = "btnDetail";
            this.btnDetail.ParentBox = null;
            this.btnDetail.Size = new System.Drawing.Size(200, 50);
            this.btnDetail.TabIndex = 206;
            this.btnDetail.Text = "점보롤 상세정보";
            this.btnDetail.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnDetail.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnDetail.UpPic = null;
            this.btnDetail.UseFlag = true;
            this.btnDetail.Click += new System.EventHandler(this.btnDetail_Click);
            // 
            // lblPrintChkName
            // 
            this.lblPrintChkName.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPrintChkName.Location = new System.Drawing.Point(270, 696);
            this.lblPrintChkName.Name = "lblPrintChkName";
            this.lblPrintChkName.Size = new System.Drawing.Size(95, 40);
            this.lblPrintChkName.TabIndex = 205;
            this.lblPrintChkName.Text = "자동인쇄";
            this.lblPrintChkName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblPrintChkName.Click += new System.EventHandler(this.lblPrintChk_Click);
            // 
            // lblPrintChk
            // 
            this.lblPrintChk.BackColor = System.Drawing.Color.Transparent;
            this.lblPrintChk.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPrintChk.ColorContent = System.Drawing.Color.Transparent;
            this.lblPrintChk.ColorLabel = System.Drawing.Color.Transparent;
            this.lblPrintChk.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPrintChk.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPrintChk.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPrintChk.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPrintChk.Location = new System.Drawing.Point(231, 696);
            this.lblPrintChk.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPrintChk.MoveControl = null;
            this.lblPrintChk.Name = "lblPrintChk";
            this.lblPrintChk.Size = new System.Drawing.Size(40, 40);
            this.lblPrintChk.TabIndex = 204;
            this.lblPrintChk.Text = "V";
            this.lblPrintChk.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPrintChk.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPrintChk.Click += new System.EventHandler(this.lblPrintChk_Click);
            // 
            // lblEndChkName
            // 
            this.lblEndChkName.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndChkName.Location = new System.Drawing.Point(50, 696);
            this.lblEndChkName.Name = "lblEndChkName";
            this.lblEndChkName.Size = new System.Drawing.Size(120, 40);
            this.lblEndChkName.TabIndex = 203;
            this.lblEndChkName.Text = "점보롤 완료";
            this.lblEndChkName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblEndChkName.Click += new System.EventHandler(this.lblEndChk_Click);
            // 
            // lblEndChk
            // 
            this.lblEndChk.BackColor = System.Drawing.Color.Transparent;
            this.lblEndChk.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEndChk.ColorContent = System.Drawing.Color.Transparent;
            this.lblEndChk.ColorLabel = System.Drawing.Color.Transparent;
            this.lblEndChk.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEndChk.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndChk.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEndChk.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEndChk.Location = new System.Drawing.Point(11, 696);
            this.lblEndChk.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndChk.MoveControl = null;
            this.lblEndChk.Name = "lblEndChk";
            this.lblEndChk.Size = new System.Drawing.Size(40, 40);
            this.lblEndChk.TabIndex = 202;
            this.lblEndChk.Text = "V";
            this.lblEndChk.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblEndChk.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndChk.Click += new System.EventHandler(this.lblEndChk_Click);
            // 
            // dtpStartDate
            // 
            this.dtpStartDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpStartDate.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDate.Location = new System.Drawing.Point(177, 480);
            this.dtpStartDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpStartDate.Name = "dtpStartDate";
            this.dtpStartDate.ShowUpDown = true;
            this.dtpStartDate.Size = new System.Drawing.Size(185, 50);
            this.dtpStartDate.TabIndex = 200;
            this.dtpStartDate.ValueChanged += new System.EventHandler(this.dtpDate_ValueChanged);
            this.dtpStartDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label21
            // 
            this.label21.BackColor = System.Drawing.Color.Black;
            this.label21.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label21.ForeColor = System.Drawing.Color.White;
            this.label21.Location = new System.Drawing.Point(426, 534);
            this.label21.Name = "label21";
            this.label21.Size = new System.Drawing.Size(165, 50);
            this.label21.TabIndex = 197;
            this.label21.Text = "선속(M/분)";
            this.label21.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPF_RSPEED
            // 
            this.lblPF_RSPEED.BackColor = System.Drawing.Color.LightGray;
            this.lblPF_RSPEED.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_RSPEED.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_RSPEED.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPF_RSPEED.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_RSPEED.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_RSPEED.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_RSPEED.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_RSPEED.Location = new System.Drawing.Point(598, 534);
            this.lblPF_RSPEED.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_RSPEED.MoveControl = null;
            this.lblPF_RSPEED.Name = "lblPF_RSPEED";
            this.lblPF_RSPEED.Size = new System.Drawing.Size(240, 50);
            this.lblPF_RSPEED.TabIndex = 198;
            this.lblPF_RSPEED.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPF_RSPEED.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label20
            // 
            this.label20.BackColor = System.Drawing.Color.Black;
            this.label20.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label20.ForeColor = System.Drawing.Color.White;
            this.label20.Location = new System.Drawing.Point(6, 534);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(165, 50);
            this.label20.TabIndex = 195;
            this.label20.Text = "권치수(M)";
            this.label20.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPF_ROLLCNT
            // 
            this.lblPF_ROLLCNT.BackColor = System.Drawing.Color.White;
            this.lblPF_ROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_ROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_ROLLCNT.ColorLabel = System.Drawing.Color.White;
            this.lblPF_ROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_ROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_ROLLCNT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_ROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_ROLLCNT.Location = new System.Drawing.Point(178, 534);
            this.lblPF_ROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_ROLLCNT.MoveControl = null;
            this.lblPF_ROLLCNT.Name = "lblPF_ROLLCNT";
            this.lblPF_ROLLCNT.Size = new System.Drawing.Size(240, 50);
            this.lblPF_ROLLCNT.TabIndex = 196;
            this.lblPF_ROLLCNT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPF_ROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPF_ROLLCNT.Click += new System.EventHandler(this.lblROLLCNT_Click);
            // 
            // lblPF_WGT
            // 
            this.lblPF_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblPF_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPF_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_WGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_WGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_WGT.Location = new System.Drawing.Point(597, 588);
            this.lblPF_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_WGT.MoveControl = null;
            this.lblPF_WGT.Name = "lblPF_WGT";
            this.lblPF_WGT.Size = new System.Drawing.Size(240, 50);
            this.lblPF_WGT.TabIndex = 194;
            this.lblPF_WGT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPF_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPF_TM
            // 
            this.lblPF_TM.BackColor = System.Drawing.Color.LightGray;
            this.lblPF_TM.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_TM.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_TM.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPF_TM.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_TM.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_TM.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_TM.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_TM.Location = new System.Drawing.Point(1016, 534);
            this.lblPF_TM.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_TM.MoveControl = null;
            this.lblPF_TM.Name = "lblPF_TM";
            this.lblPF_TM.Size = new System.Drawing.Size(240, 50);
            this.lblPF_TM.TabIndex = 193;
            this.lblPF_TM.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPF_TM.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblEndTime
            // 
            this.lblEndTime.BackColor = System.Drawing.Color.White;
            this.lblEndTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEndTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblEndTime.ColorLabel = System.Drawing.Color.White;
            this.lblEndTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEndTime.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEndTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEndTime.Location = new System.Drawing.Point(717, 480);
            this.lblEndTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndTime.MoveControl = null;
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(120, 50);
            this.lblEndTime.TabIndex = 191;
            this.lblEndTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblEndTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // lblWO_JWIDTH
            // 
            this.lblWO_JWIDTH.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_JWIDTH.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_JWIDTH.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_JWIDTH.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_JWIDTH.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_JWIDTH.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_JWIDTH.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_JWIDTH.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_JWIDTH.Location = new System.Drawing.Point(1108, 112);
            this.lblWO_JWIDTH.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_JWIDTH.MoveControl = null;
            this.lblWO_JWIDTH.Name = "lblWO_JWIDTH";
            this.lblWO_JWIDTH.Size = new System.Drawing.Size(150, 50);
            this.lblWO_JWIDTH.TabIndex = 189;
            this.lblWO_JWIDTH.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_JWIDTH.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label17
            // 
            this.label17.BackColor = System.Drawing.Color.Black;
            this.label17.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label17.ForeColor = System.Drawing.Color.White;
            this.label17.Location = new System.Drawing.Point(6, 641);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(165, 50);
            this.label17.TabIndex = 185;
            this.label17.Text = "비고";
            this.label17.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPF_WRK_ORDR_RMK
            // 
            this.lblPF_WRK_ORDR_RMK.BackColor = System.Drawing.Color.White;
            this.lblPF_WRK_ORDR_RMK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_WRK_ORDR_RMK.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_WRK_ORDR_RMK.ColorLabel = System.Drawing.Color.White;
            this.lblPF_WRK_ORDR_RMK.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_WRK_ORDR_RMK.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_WRK_ORDR_RMK.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_WRK_ORDR_RMK.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_WRK_ORDR_RMK.Location = new System.Drawing.Point(178, 641);
            this.lblPF_WRK_ORDR_RMK.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_WRK_ORDR_RMK.MoveControl = null;
            this.lblPF_WRK_ORDR_RMK.Name = "lblPF_WRK_ORDR_RMK";
            this.lblPF_WRK_ORDR_RMK.Size = new System.Drawing.Size(1080, 50);
            this.lblPF_WRK_ORDR_RMK.TabIndex = 186;
            this.lblPF_WRK_ORDR_RMK.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPF_WRK_ORDR_RMK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPF_WRK_ORDR_RMK.Click += new System.EventHandler(this.lblRemark_Click);
            // 
            // label18
            // 
            this.label18.BackColor = System.Drawing.Color.Black;
            this.label18.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label18.ForeColor = System.Drawing.Color.White;
            this.label18.Location = new System.Drawing.Point(6, 588);
            this.label18.Name = "label18";
            this.label18.Size = new System.Drawing.Size(165, 50);
            this.label18.TabIndex = 187;
            this.label18.Text = "R/W지폭합";
            this.label18.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPF_MWIDTH
            // 
            this.lblPF_MWIDTH.BackColor = System.Drawing.Color.LightGray;
            this.lblPF_MWIDTH.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPF_MWIDTH.ColorContent = System.Drawing.Color.Transparent;
            this.lblPF_MWIDTH.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPF_MWIDTH.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPF_MWIDTH.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPF_MWIDTH.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPF_MWIDTH.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPF_MWIDTH.Location = new System.Drawing.Point(178, 588);
            this.lblPF_MWIDTH.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPF_MWIDTH.MoveControl = null;
            this.lblPF_MWIDTH.Name = "lblPF_MWIDTH";
            this.lblPF_MWIDTH.Size = new System.Drawing.Size(240, 50);
            this.lblPF_MWIDTH.TabIndex = 188;
            this.lblPF_MWIDTH.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPF_MWIDTH.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label15
            // 
            this.label15.BackColor = System.Drawing.Color.Black;
            this.label15.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label15.ForeColor = System.Drawing.Color.White;
            this.label15.Location = new System.Drawing.Point(845, 480);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(165, 50);
            this.label15.TabIndex = 181;
            this.label15.Text = "생산실적일자";
            this.label15.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label16
            // 
            this.label16.BackColor = System.Drawing.Color.Black;
            this.label16.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label16.ForeColor = System.Drawing.Color.White;
            this.label16.Location = new System.Drawing.Point(845, 534);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(165, 50);
            this.label16.TabIndex = 183;
            this.label16.Text = "가동시간(분)";
            this.label16.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Black;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(6, 480);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(165, 50);
            this.label13.TabIndex = 177;
            this.label13.Text = "작업일시";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Black;
            this.label14.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(426, 588);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(165, 50);
            this.label14.TabIndex = 179;
            this.label14.Text = "중량(Kg)";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblStartTime
            // 
            this.lblStartTime.BackColor = System.Drawing.Color.White;
            this.lblStartTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStartTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblStartTime.ColorLabel = System.Drawing.Color.White;
            this.lblStartTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStartTime.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStartTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblStartTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStartTime.Location = new System.Drawing.Point(365, 480);
            this.lblStartTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTime.MoveControl = null;
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(120, 50);
            this.lblStartTime.TabIndex = 176;
            this.lblStartTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblStartTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(6, 271);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(165, 50);
            this.label9.TabIndex = 169;
            this.label9.Text = "목표선속(M/분)";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(636, 271);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(165, 50);
            this.label10.TabIndex = 171;
            this.label10.Text = "폐품량";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_DISPO_QTY
            // 
            this.lblWO_DISPO_QTY.BackColor = System.Drawing.Color.Black;
            this.lblWO_DISPO_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_DISPO_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_DISPO_QTY.ColorLabel = System.Drawing.Color.Black;
            this.lblWO_DISPO_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_DISPO_QTY.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_DISPO_QTY.ForeColor = System.Drawing.Color.Lime;
            this.lblWO_DISPO_QTY.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_DISPO_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_DISPO_QTY.Location = new System.Drawing.Point(808, 271);
            this.lblWO_DISPO_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_DISPO_QTY.MoveControl = null;
            this.lblWO_DISPO_QTY.Name = "lblWO_DISPO_QTY";
            this.lblWO_DISPO_QTY.Size = new System.Drawing.Size(450, 50);
            this.lblWO_DISPO_QTY.TabIndex = 172;
            this.lblWO_DISPO_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_DISPO_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(6, 218);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(165, 50);
            this.label7.TabIndex = 165;
            this.label7.Text = "계획중량";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_TOT_WGT
            // 
            this.lblWO_TOT_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_TOT_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_TOT_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_TOT_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_TOT_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_TOT_WGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_TOT_WGT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_TOT_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_TOT_WGT.Location = new System.Drawing.Point(178, 218);
            this.lblWO_TOT_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_TOT_WGT.MoveControl = null;
            this.lblWO_TOT_WGT.Name = "lblWO_TOT_WGT";
            this.lblWO_TOT_WGT.Size = new System.Drawing.Size(450, 50);
            this.lblWO_TOT_WGT.TabIndex = 166;
            this.lblWO_TOT_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_TOT_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Gray;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(636, 218);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(165, 50);
            this.label8.TabIndex = 167;
            this.label8.Text = "실적중량";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_PRFM_WGT
            // 
            this.lblWO_PRFM_WGT.BackColor = System.Drawing.Color.Black;
            this.lblWO_PRFM_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_PRFM_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_PRFM_WGT.ColorLabel = System.Drawing.Color.Black;
            this.lblWO_PRFM_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_PRFM_WGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_PRFM_WGT.ForeColor = System.Drawing.Color.Lime;
            this.lblWO_PRFM_WGT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_PRFM_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_PRFM_WGT.Location = new System.Drawing.Point(808, 218);
            this.lblWO_PRFM_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_PRFM_WGT.MoveControl = null;
            this.lblWO_PRFM_WGT.Name = "lblWO_PRFM_WGT";
            this.lblWO_PRFM_WGT.Size = new System.Drawing.Size(450, 50);
            this.lblWO_PRFM_WGT.TabIndex = 168;
            this.lblWO_PRFM_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_PRFM_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(6, 165);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(165, 50);
            this.label5.TabIndex = 161;
            this.label5.Text = "계획권치수";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_JROLLCNT
            // 
            this.lblWO_JROLLCNT.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_JROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_JROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_JROLLCNT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_JROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_JROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_JROLLCNT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_JROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_JROLLCNT.Location = new System.Drawing.Point(178, 165);
            this.lblWO_JROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_JROLLCNT.MoveControl = null;
            this.lblWO_JROLLCNT.Name = "lblWO_JROLLCNT";
            this.lblWO_JROLLCNT.Size = new System.Drawing.Size(450, 50);
            this.lblWO_JROLLCNT.TabIndex = 162;
            this.lblWO_JROLLCNT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_JROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(636, 165);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(165, 50);
            this.label6.TabIndex = 163;
            this.label6.Text = "실적권치수";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_PRFM_ROLLCNT
            // 
            this.lblWO_PRFM_ROLLCNT.BackColor = System.Drawing.Color.Black;
            this.lblWO_PRFM_ROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_PRFM_ROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_PRFM_ROLLCNT.ColorLabel = System.Drawing.Color.Black;
            this.lblWO_PRFM_ROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_PRFM_ROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_PRFM_ROLLCNT.ForeColor = System.Drawing.Color.Lime;
            this.lblWO_PRFM_ROLLCNT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_PRFM_ROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_PRFM_ROLLCNT.Location = new System.Drawing.Point(808, 165);
            this.lblWO_PRFM_ROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_PRFM_ROLLCNT.MoveControl = null;
            this.lblWO_PRFM_ROLLCNT.Name = "lblWO_PRFM_ROLLCNT";
            this.lblWO_PRFM_ROLLCNT.Size = new System.Drawing.Size(450, 50);
            this.lblWO_PRFM_ROLLCNT.TabIndex = 164;
            this.lblWO_PRFM_ROLLCNT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_PRFM_ROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(6, 112);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(165, 50);
            this.label2.TabIndex = 157;
            this.label2.Text = "자재코드";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_MATNR
            // 
            this.lblWO_MATNR.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_MATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_MATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_MATNR.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_MATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_MATNR.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_MATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWO_MATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_MATNR.Location = new System.Drawing.Point(178, 112);
            this.lblWO_MATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_MATNR.MoveControl = null;
            this.lblWO_MATNR.Name = "lblWO_MATNR";
            this.lblWO_MATNR.Size = new System.Drawing.Size(450, 50);
            this.lblWO_MATNR.TabIndex = 158;
            this.lblWO_MATNR.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWO_MATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(636, 112);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(165, 50);
            this.label4.TabIndex = 159;
            this.label4.Text = "지종/평량/지폭";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_BS_WGT
            // 
            this.lblWO_BS_WGT.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_BS_WGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_BS_WGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_BS_WGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_BS_WGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_BS_WGT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_BS_WGT.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblWO_BS_WGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_BS_WGT.Location = new System.Drawing.Point(958, 112);
            this.lblWO_BS_WGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_BS_WGT.MoveControl = null;
            this.lblWO_BS_WGT.Name = "lblWO_BS_WGT";
            this.lblWO_BS_WGT.Size = new System.Drawing.Size(150, 50);
            this.lblWO_BS_WGT.TabIndex = 160;
            this.lblWO_BS_WGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWO_BS_WGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(6, 59);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(165, 50);
            this.label1.TabIndex = 152;
            this.label1.Text = "작업지시번호";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_WRK_ORDR_NO
            // 
            this.lblWO_WRK_ORDR_NO.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_WRK_ORDR_NO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_WRK_ORDR_NO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_WRK_ORDR_NO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_WRK_ORDR_NO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_WRK_ORDR_NO.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_WRK_ORDR_NO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWO_WRK_ORDR_NO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_WRK_ORDR_NO.Location = new System.Drawing.Point(178, 59);
            this.lblWO_WRK_ORDR_NO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_WRK_ORDR_NO.MoveControl = null;
            this.lblWO_WRK_ORDR_NO.Name = "lblWO_WRK_ORDR_NO";
            this.lblWO_WRK_ORDR_NO.Size = new System.Drawing.Size(350, 50);
            this.lblWO_WRK_ORDR_NO.TabIndex = 153;
            this.lblWO_WRK_ORDR_NO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWO_WRK_ORDR_NO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(636, 59);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(165, 50);
            this.label3.TabIndex = 155;
            this.label3.Text = "생산요청일";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWO_PRD_REQ_DT
            // 
            this.lblWO_PRD_REQ_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblWO_PRD_REQ_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWO_PRD_REQ_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWO_PRD_REQ_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWO_PRD_REQ_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWO_PRD_REQ_DT.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWO_PRD_REQ_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWO_PRD_REQ_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWO_PRD_REQ_DT.Location = new System.Drawing.Point(808, 59);
            this.lblWO_PRD_REQ_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWO_PRD_REQ_DT.MoveControl = null;
            this.lblWO_PRD_REQ_DT.Name = "lblWO_PRD_REQ_DT";
            this.lblWO_PRD_REQ_DT.Size = new System.Drawing.Size(450, 50);
            this.lblWO_PRD_REQ_DT.TabIndex = 156;
            this.lblWO_PRD_REQ_DT.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWO_PRD_REQ_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.MidnightBlue;
            this.bBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 24F;
            this.bBox1.Location = new System.Drawing.Point(0, 0);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(1274, 81);
            this.bBox1.TabIndex = 66;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // timer1
            // 
            this.timer1.Interval = 1000;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // POP_WRK24
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK24";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK24_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.Label label1;
        private MESLabel lblWO_WRK_ORDR_NO;
        private System.Windows.Forms.Label label3;
        private MESLabel lblWO_PRD_REQ_DT;
        private ButtonBox bBox1;
        private MESLabel lblEndTime;
        private MESLabel lblWO_JWIDTH;
        private System.Windows.Forms.Label label17;
        private System.Windows.Forms.Label label18;
        private MESLabel lblPF_MWIDTH;
        private System.Windows.Forms.Label label15;
        private System.Windows.Forms.Label label16;
        private System.Windows.Forms.Label label13;
        private System.Windows.Forms.Label label14;
        private MESLabel lblStartTime;
        private System.Windows.Forms.Label label10;
        private MESLabel lblWO_DISPO_QTY;
        private System.Windows.Forms.Label label7;
        private MESLabel lblWO_TOT_WGT;
        private System.Windows.Forms.Label label8;
        private MESLabel lblWO_PRFM_WGT;
        private System.Windows.Forms.Label label5;
        private MESLabel lblWO_JROLLCNT;
        private System.Windows.Forms.Label label6;
        private MESLabel lblWO_PRFM_ROLLCNT;
        private System.Windows.Forms.Label label2;
        private MESLabel lblWO_MATNR;
        private System.Windows.Forms.Label label4;
        private MESLabel lblWO_BS_WGT;
        private System.Windows.Forms.Label label21;
        private MESLabel lblPF_RSPEED;
        private System.Windows.Forms.Label label20;
        private MESLabel lblPF_ROLLCNT;
        private MESLabel lblPF_WGT;
        private MESLabel lblPF_TM;
        private System.Windows.Forms.Label lblPrintChkName;
        private MESLabel lblPrintChk;
        private System.Windows.Forms.Label lblEndChkName;
        private MESLabel lblEndChk;
        private MESDateTimePicker dtpStartDate;
        private MESLabel lblPF_WRK_ORDR_RMK;
        private MESButton btnDetail;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label26;
        private MESLabel lblNonOrderCode;
        private System.Windows.Forms.Label label27;
        private MESLabel lblNonOrderName;
        private System.Windows.Forms.Label label24;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Label lblMACH_STA;
        private MESButton btnNonOrder;
        private System.Windows.Forms.Label label12;
        private MESDateTimePicker dtpEndDate;
        private System.Windows.Forms.Button butStartDate;
        private System.Windows.Forms.Button butEndDate;
        private MESLabel lblPF_PRFM_DT;
        private System.Windows.Forms.TextBox txtWO_ORDER_RMK;
        private MESLabel lblWO_WRK_ORDR_SEQNO;
        private MESLabel lblWO_TSPEED;
        private System.Windows.Forms.Label label22;
        private MESLabel lblNonOrderBS_WGT;
        private MESLabel lblWO_PCODE;
        private System.Windows.Forms.Timer timer1;

    }
}
