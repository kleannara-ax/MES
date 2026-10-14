using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK18
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
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblEndChkName = new System.Windows.Forms.Label();
            this.lblEndChk = new SmartDas.Components.MESLabel();
            this.lblPRFM_DATE = new SmartDas.Components.MESLabel();
            this.label21 = new System.Windows.Forms.Label();
            this.lblSIZE = new SmartDas.Components.MESLabel();
            this.lblMATNR_SPEC = new SmartDas.Components.MESLabel();
            this.label11 = new System.Windows.Forms.Label();
            this.lblTOT_EA = new SmartDas.Components.MESLabel();
            this.label15 = new System.Windows.Forms.Label();
            this.lblTOT_BAG = new SmartDas.Components.MESLabel();
            this.label16 = new System.Windows.Forms.Label();
            this.lblTOT_BOX = new SmartDas.Components.MESLabel();
            this.label23 = new System.Windows.Forms.Label();
            this.lblTOT_PLT = new SmartDas.Components.MESLabel();
            this.label24 = new System.Windows.Forms.Label();
            this.lblLOT_NO = new SmartDas.Components.MESLabel();
            this.label22 = new System.Windows.Forms.Label();
            this.lblPRFM_EA = new SmartDas.Components.MESLabel();
            this.label17 = new System.Windows.Forms.Label();
            this.lblPRFM_BAG = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.lblEA_QTY = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.lblBAG_QTY = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.lblBOX_QTY = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblPLT_QTY = new SmartDas.Components.MESLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_RMK = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label18 = new System.Windows.Forms.Label();
            this.lblPRD_REQ_DT = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.label19 = new System.Windows.Forms.Label();
            this.label20 = new System.Windows.Forms.Label();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.label14 = new System.Windows.Forms.Label();
            this.lblPRFM_BOX = new SmartDas.Components.MESLabel();
            this.label12 = new System.Windows.Forms.Label();
            this.lblPRFM_PLT = new SmartDas.Components.MESLabel();
            this.label10 = new System.Windows.Forms.Label();
            this.lblIND_BCD = new SmartDas.Components.MESLabel();
            this.label9 = new System.Windows.Forms.Label();
            this.label13 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
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
            this.bBox1.TabIndex = 64;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
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
            this.splitContainer1.Panel1.Controls.Add(this.lblEndChkName);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndChk);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label21);
            this.splitContainer1.Panel1.Controls.Add(this.lblSIZE);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR_SPEC);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblTOT_EA);
            this.splitContainer1.Panel1.Controls.Add(this.label15);
            this.splitContainer1.Panel1.Controls.Add(this.lblTOT_BAG);
            this.splitContainer1.Panel1.Controls.Add(this.label16);
            this.splitContainer1.Panel1.Controls.Add(this.lblTOT_BOX);
            this.splitContainer1.Panel1.Controls.Add(this.label23);
            this.splitContainer1.Panel1.Controls.Add(this.lblTOT_PLT);
            this.splitContainer1.Panel1.Controls.Add(this.label24);
            this.splitContainer1.Panel1.Controls.Add(this.lblLOT_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label22);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_EA);
            this.splitContainer1.Panel1.Controls.Add(this.label17);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_BAG);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblEA_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblBAG_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblBOX_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblPLT_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label18);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DT);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.label19);
            this.splitContainer1.Panel1.Controls.Add(this.label20);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_BOX);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_PLT);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblIND_BCD);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblEndChkName
            // 
            this.lblEndChkName.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.lblEndChkName.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndChkName.ForeColor = System.Drawing.SystemColors.ControlText;
            this.lblEndChkName.Location = new System.Drawing.Point(1135, 386);
            this.lblEndChkName.Name = "lblEndChkName";
            this.lblEndChkName.Size = new System.Drawing.Size(120, 40);
            this.lblEndChkName.TabIndex = 263;
            this.lblEndChkName.Text = "생산 완료";
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
            this.lblEndChk.Location = new System.Drawing.Point(1096, 386);
            this.lblEndChk.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndChk.MoveControl = null;
            this.lblEndChk.Name = "lblEndChk";
            this.lblEndChk.Size = new System.Drawing.Size(40, 40);
            this.lblEndChk.TabIndex = 262;
            this.lblEndChk.Text = "V";
            this.lblEndChk.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblEndChk.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndChk.Click += new System.EventHandler(this.lblEndChk_Click);
            // 
            // lblPRFM_DATE
            // 
            this.lblPRFM_DATE.BackColor = System.Drawing.Color.LightGray;
            this.lblPRFM_DATE.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_DATE.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_DATE.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRFM_DATE.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_DATE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_DATE.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_DATE.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_DATE.Location = new System.Drawing.Point(171, 437);
            this.lblPRFM_DATE.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_DATE.MoveControl = null;
            this.lblPRFM_DATE.Name = "lblPRFM_DATE";
            this.lblPRFM_DATE.Size = new System.Drawing.Size(460, 50);
            this.lblPRFM_DATE.TabIndex = 262;
            this.lblPRFM_DATE.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPRFM_DATE.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label21
            // 
            this.label21.BackColor = System.Drawing.Color.Gray;
            this.label21.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label21.ForeColor = System.Drawing.Color.White;
            this.label21.Location = new System.Drawing.Point(15, 239);
            this.label21.Name = "label21";
            this.label21.Size = new System.Drawing.Size(150, 50);
            this.label21.TabIndex = 260;
            this.label21.Text = "SIZE/규격";
            this.label21.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblSIZE
            // 
            this.lblSIZE.BackColor = System.Drawing.Color.LightGray;
            this.lblSIZE.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblSIZE.ColorContent = System.Drawing.Color.Transparent;
            this.lblSIZE.ColorLabel = System.Drawing.Color.LightGray;
            this.lblSIZE.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblSIZE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblSIZE.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblSIZE.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblSIZE.Location = new System.Drawing.Point(171, 240);
            this.lblSIZE.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblSIZE.MoveControl = null;
            this.lblSIZE.Name = "lblSIZE";
            this.lblSIZE.Size = new System.Drawing.Size(330, 50);
            this.lblSIZE.TabIndex = 261;
            this.lblSIZE.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblSIZE.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblMATNR_SPEC
            // 
            this.lblMATNR_SPEC.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR_SPEC.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR_SPEC.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR_SPEC.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR_SPEC.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR_SPEC.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR_SPEC.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR_SPEC.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR_SPEC.Location = new System.Drawing.Point(511, 240);
            this.lblMATNR_SPEC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR_SPEC.MoveControl = null;
            this.lblMATNR_SPEC.Name = "lblMATNR_SPEC";
            this.lblMATNR_SPEC.Size = new System.Drawing.Size(330, 50);
            this.lblMATNR_SPEC.TabIndex = 259;
            this.lblMATNR_SPEC.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR_SPEC.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.Gray;
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.White;
            this.label11.Location = new System.Drawing.Point(639, 717);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(150, 50);
            this.label11.TabIndex = 254;
            this.label11.Text = "EA";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTOT_EA
            // 
            this.lblTOT_EA.BackColor = System.Drawing.Color.Silver;
            this.lblTOT_EA.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTOT_EA.ColorContent = System.Drawing.Color.Transparent;
            this.lblTOT_EA.ColorLabel = System.Drawing.Color.Silver;
            this.lblTOT_EA.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTOT_EA.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTOT_EA.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTOT_EA.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTOT_EA.Location = new System.Drawing.Point(795, 718);
            this.lblTOT_EA.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTOT_EA.MoveControl = null;
            this.lblTOT_EA.Name = "lblTOT_EA";
            this.lblTOT_EA.Size = new System.Drawing.Size(460, 50);
            this.lblTOT_EA.TabIndex = 255;
            this.lblTOT_EA.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTOT_EA.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label15
            // 
            this.label15.BackColor = System.Drawing.Color.Gray;
            this.label15.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label15.ForeColor = System.Drawing.Color.White;
            this.label15.Location = new System.Drawing.Point(639, 662);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(150, 50);
            this.label15.TabIndex = 252;
            this.label15.Text = "BAG";
            this.label15.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTOT_BAG
            // 
            this.lblTOT_BAG.BackColor = System.Drawing.Color.Silver;
            this.lblTOT_BAG.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTOT_BAG.ColorContent = System.Drawing.Color.Transparent;
            this.lblTOT_BAG.ColorLabel = System.Drawing.Color.Silver;
            this.lblTOT_BAG.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTOT_BAG.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTOT_BAG.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTOT_BAG.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTOT_BAG.Location = new System.Drawing.Point(795, 663);
            this.lblTOT_BAG.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTOT_BAG.MoveControl = null;
            this.lblTOT_BAG.Name = "lblTOT_BAG";
            this.lblTOT_BAG.Size = new System.Drawing.Size(460, 50);
            this.lblTOT_BAG.TabIndex = 253;
            this.lblTOT_BAG.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTOT_BAG.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label16
            // 
            this.label16.BackColor = System.Drawing.Color.Gray;
            this.label16.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label16.ForeColor = System.Drawing.Color.White;
            this.label16.Location = new System.Drawing.Point(639, 607);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(150, 50);
            this.label16.TabIndex = 250;
            this.label16.Text = "BOX";
            this.label16.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTOT_BOX
            // 
            this.lblTOT_BOX.BackColor = System.Drawing.Color.Silver;
            this.lblTOT_BOX.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTOT_BOX.ColorContent = System.Drawing.Color.Transparent;
            this.lblTOT_BOX.ColorLabel = System.Drawing.Color.Silver;
            this.lblTOT_BOX.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTOT_BOX.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTOT_BOX.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTOT_BOX.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTOT_BOX.Location = new System.Drawing.Point(795, 608);
            this.lblTOT_BOX.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTOT_BOX.MoveControl = null;
            this.lblTOT_BOX.Name = "lblTOT_BOX";
            this.lblTOT_BOX.Size = new System.Drawing.Size(460, 50);
            this.lblTOT_BOX.TabIndex = 251;
            this.lblTOT_BOX.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTOT_BOX.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label23
            // 
            this.label23.BackColor = System.Drawing.Color.Gray;
            this.label23.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label23.ForeColor = System.Drawing.Color.White;
            this.label23.Location = new System.Drawing.Point(639, 551);
            this.label23.Name = "label23";
            this.label23.Size = new System.Drawing.Size(150, 50);
            this.label23.TabIndex = 248;
            this.label23.Text = "PLT";
            this.label23.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTOT_PLT
            // 
            this.lblTOT_PLT.BackColor = System.Drawing.Color.Silver;
            this.lblTOT_PLT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTOT_PLT.ColorContent = System.Drawing.Color.Transparent;
            this.lblTOT_PLT.ColorLabel = System.Drawing.Color.Silver;
            this.lblTOT_PLT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTOT_PLT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTOT_PLT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTOT_PLT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTOT_PLT.Location = new System.Drawing.Point(795, 552);
            this.lblTOT_PLT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTOT_PLT.MoveControl = null;
            this.lblTOT_PLT.Name = "lblTOT_PLT";
            this.lblTOT_PLT.Size = new System.Drawing.Size(460, 50);
            this.lblTOT_PLT.TabIndex = 249;
            this.lblTOT_PLT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTOT_PLT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label24
            // 
            this.label24.BackColor = System.Drawing.Color.Gray;
            this.label24.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label24.ForeColor = System.Drawing.Color.White;
            this.label24.Location = new System.Drawing.Point(639, 495);
            this.label24.Name = "label24";
            this.label24.Size = new System.Drawing.Size(150, 50);
            this.label24.TabIndex = 246;
            this.label24.Text = "Lot번호";
            this.label24.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLOT_NO
            // 
            this.lblLOT_NO.BackColor = System.Drawing.Color.Silver;
            this.lblLOT_NO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLOT_NO.ColorContent = System.Drawing.Color.Transparent;
            this.lblLOT_NO.ColorLabel = System.Drawing.Color.Silver;
            this.lblLOT_NO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLOT_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLOT_NO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblLOT_NO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLOT_NO.Location = new System.Drawing.Point(795, 496);
            this.lblLOT_NO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblLOT_NO.MoveControl = null;
            this.lblLOT_NO.Name = "lblLOT_NO";
            this.lblLOT_NO.Size = new System.Drawing.Size(460, 50);
            this.lblLOT_NO.TabIndex = 247;
            this.lblLOT_NO.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblLOT_NO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label22
            // 
            this.label22.BackColor = System.Drawing.Color.Gray;
            this.label22.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label22.ForeColor = System.Drawing.Color.White;
            this.label22.Location = new System.Drawing.Point(15, 717);
            this.label22.Name = "label22";
            this.label22.Size = new System.Drawing.Size(150, 50);
            this.label22.TabIndex = 244;
            this.label22.Text = "EA";
            this.label22.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_EA
            // 
            this.lblPRFM_EA.BackColor = System.Drawing.Color.Silver;
            this.lblPRFM_EA.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_EA.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_EA.ColorLabel = System.Drawing.Color.Silver;
            this.lblPRFM_EA.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_EA.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_EA.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_EA.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_EA.Location = new System.Drawing.Point(171, 718);
            this.lblPRFM_EA.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_EA.MoveControl = null;
            this.lblPRFM_EA.Name = "lblPRFM_EA";
            this.lblPRFM_EA.Size = new System.Drawing.Size(460, 50);
            this.lblPRFM_EA.TabIndex = 245;
            this.lblPRFM_EA.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_EA.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label17
            // 
            this.label17.BackColor = System.Drawing.Color.Gray;
            this.label17.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label17.ForeColor = System.Drawing.Color.White;
            this.label17.Location = new System.Drawing.Point(15, 662);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(150, 50);
            this.label17.TabIndex = 242;
            this.label17.Text = "BAG";
            this.label17.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_BAG
            // 
            this.lblPRFM_BAG.BackColor = System.Drawing.Color.Silver;
            this.lblPRFM_BAG.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_BAG.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_BAG.ColorLabel = System.Drawing.Color.Silver;
            this.lblPRFM_BAG.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_BAG.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_BAG.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_BAG.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_BAG.Location = new System.Drawing.Point(171, 663);
            this.lblPRFM_BAG.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_BAG.MoveControl = null;
            this.lblPRFM_BAG.Name = "lblPRFM_BAG";
            this.lblPRFM_BAG.Size = new System.Drawing.Size(460, 50);
            this.lblPRFM_BAG.TabIndex = 243;
            this.lblPRFM_BAG.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_BAG.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(847, 299);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 240;
            this.label1.Text = "EA";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblEA_QTY
            // 
            this.lblEA_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblEA_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEA_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblEA_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblEA_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEA_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEA_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEA_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEA_QTY.Location = new System.Drawing.Point(1005, 299);
            this.lblEA_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEA_QTY.MoveControl = null;
            this.lblEA_QTY.Name = "lblEA_QTY";
            this.lblEA_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblEA_QTY.TabIndex = 241;
            this.lblEA_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblEA_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(847, 240);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 238;
            this.label2.Text = "BAG";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblBAG_QTY
            // 
            this.lblBAG_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblBAG_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBAG_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblBAG_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBAG_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBAG_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBAG_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBAG_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBAG_QTY.Location = new System.Drawing.Point(1005, 240);
            this.lblBAG_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBAG_QTY.MoveControl = null;
            this.lblBAG_QTY.Name = "lblBAG_QTY";
            this.lblBAG_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblBAG_QTY.TabIndex = 239;
            this.lblBAG_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBAG_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(847, 183);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 236;
            this.label3.Text = "BOX";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblBOX_QTY
            // 
            this.lblBOX_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblBOX_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBOX_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblBOX_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBOX_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBOX_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBOX_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBOX_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBOX_QTY.Location = new System.Drawing.Point(1005, 183);
            this.lblBOX_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBOX_QTY.MoveControl = null;
            this.lblBOX_QTY.Name = "lblBOX_QTY";
            this.lblBOX_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblBOX_QTY.TabIndex = 237;
            this.lblBOX_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBOX_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(847, 125);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(150, 50);
            this.label4.TabIndex = 234;
            this.label4.Text = "PLT";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPLT_QTY
            // 
            this.lblPLT_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblPLT_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPLT_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblPLT_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPLT_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPLT_QTY.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPLT_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPLT_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPLT_QTY.Location = new System.Drawing.Point(1005, 125);
            this.lblPLT_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPLT_QTY.MoveControl = null;
            this.lblPLT_QTY.Name = "lblPLT_QTY";
            this.lblPLT_QTY.Size = new System.Drawing.Size(250, 50);
            this.lblPLT_QTY.TabIndex = 235;
            this.lblPLT_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPLT_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(15, 299);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(150, 50);
            this.label6.TabIndex = 232;
            this.label6.Text = "비고";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_RMK
            // 
            this.lblWRK_ORDR_RMK.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_RMK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_RMK.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_RMK.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_RMK.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_RMK.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_RMK.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_RMK.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_RMK.Location = new System.Drawing.Point(171, 299);
            this.lblWRK_ORDR_RMK.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_RMK.MoveControl = null;
            this.lblWRK_ORDR_RMK.Name = "lblWRK_ORDR_RMK";
            this.lblWRK_ORDR_RMK.Size = new System.Drawing.Size(670, 50);
            this.lblWRK_ORDR_RMK.TabIndex = 233;
            this.lblWRK_ORDR_RMK.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWRK_ORDR_RMK.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(15, 125);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(150, 50);
            this.label5.TabIndex = 230;
            this.label5.Text = "작업지시번호";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_NO
            // 
            this.lblWRK_ORDR_NO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_NO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_NO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_NO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_NO.Location = new System.Drawing.Point(171, 126);
            this.lblWRK_ORDR_NO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_NO.MoveControl = null;
            this.lblWRK_ORDR_NO.Name = "lblWRK_ORDR_NO";
            this.lblWRK_ORDR_NO.Size = new System.Drawing.Size(480, 50);
            this.lblWRK_ORDR_NO.TabIndex = 231;
            this.lblWRK_ORDR_NO.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWRK_ORDR_NO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label18
            // 
            this.label18.BackColor = System.Drawing.Color.Gray;
            this.label18.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label18.ForeColor = System.Drawing.Color.White;
            this.label18.Location = new System.Drawing.Point(847, 69);
            this.label18.Name = "label18";
            this.label18.Size = new System.Drawing.Size(408, 50);
            this.label18.TabIndex = 228;
            this.label18.Text = "계획량";
            this.label18.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRD_REQ_DT
            // 
            this.lblPRD_REQ_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_REQ_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_REQ_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_REQ_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_REQ_DT.Location = new System.Drawing.Point(171, 69);
            this.lblPRD_REQ_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_REQ_DT.MoveControl = null;
            this.lblPRD_REQ_DT.Name = "lblPRD_REQ_DT";
            this.lblPRD_REQ_DT.Size = new System.Drawing.Size(670, 50);
            this.lblPRD_REQ_DT.TabIndex = 227;
            this.lblPRD_REQ_DT.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPRD_REQ_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWRK_ORDR_SEQNO
            // 
            this.lblWRK_ORDR_SEQNO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_SEQNO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_SEQNO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_SEQNO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_SEQNO.Location = new System.Drawing.Point(661, 125);
            this.lblWRK_ORDR_SEQNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_SEQNO.MoveControl = null;
            this.lblWRK_ORDR_SEQNO.Name = "lblWRK_ORDR_SEQNO";
            this.lblWRK_ORDR_SEQNO.Size = new System.Drawing.Size(180, 50);
            this.lblWRK_ORDR_SEQNO.TabIndex = 226;
            this.lblWRK_ORDR_SEQNO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_SEQNO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label19
            // 
            this.label19.BackColor = System.Drawing.Color.Gray;
            this.label19.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label19.ForeColor = System.Drawing.Color.White;
            this.label19.Location = new System.Drawing.Point(15, 69);
            this.label19.Name = "label19";
            this.label19.Size = new System.Drawing.Size(150, 50);
            this.label19.TabIndex = 221;
            this.label19.Text = "생산요청일";
            this.label19.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label20
            // 
            this.label20.BackColor = System.Drawing.Color.Gray;
            this.label20.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label20.ForeColor = System.Drawing.Color.White;
            this.label20.Location = new System.Drawing.Point(15, 183);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(150, 50);
            this.label20.TabIndex = 222;
            this.label20.Text = "품목";
            this.label20.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR.Location = new System.Drawing.Point(171, 183);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(670, 50);
            this.lblMATNR.TabIndex = 223;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Gray;
            this.label14.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(15, 607);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(150, 50);
            this.label14.TabIndex = 213;
            this.label14.Text = "BOX";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_BOX
            // 
            this.lblPRFM_BOX.BackColor = System.Drawing.Color.White;
            this.lblPRFM_BOX.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_BOX.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_BOX.ColorLabel = System.Drawing.Color.White;
            this.lblPRFM_BOX.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_BOX.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_BOX.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_BOX.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_BOX.Location = new System.Drawing.Point(171, 608);
            this.lblPRFM_BOX.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_BOX.MoveControl = null;
            this.lblPRFM_BOX.Name = "lblPRFM_BOX";
            this.lblPRFM_BOX.Size = new System.Drawing.Size(460, 50);
            this.lblPRFM_BOX.TabIndex = 214;
            this.lblPRFM_BOX.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_BOX.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRFM_BOX.Click += new System.EventHandler(this.lblPRFM_BOX_Click);
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.Gray;
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.White;
            this.label12.Location = new System.Drawing.Point(15, 551);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(150, 50);
            this.label12.TabIndex = 211;
            this.label12.Text = "PLT";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPRFM_PLT
            // 
            this.lblPRFM_PLT.BackColor = System.Drawing.Color.Silver;
            this.lblPRFM_PLT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_PLT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_PLT.ColorLabel = System.Drawing.Color.Silver;
            this.lblPRFM_PLT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_PLT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_PLT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_PLT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_PLT.Location = new System.Drawing.Point(171, 552);
            this.lblPRFM_PLT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_PLT.MoveControl = null;
            this.lblPRFM_PLT.Name = "lblPRFM_PLT";
            this.lblPRFM_PLT.Size = new System.Drawing.Size(460, 50);
            this.lblPRFM_PLT.TabIndex = 212;
            this.lblPRFM_PLT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPRFM_PLT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(15, 494);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(150, 50);
            this.label10.TabIndex = 206;
            this.label10.Text = "개별바코드";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblIND_BCD
            // 
            this.lblIND_BCD.BackColor = System.Drawing.Color.Silver;
            this.lblIND_BCD.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblIND_BCD.ColorContent = System.Drawing.Color.Transparent;
            this.lblIND_BCD.ColorLabel = System.Drawing.Color.Silver;
            this.lblIND_BCD.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblIND_BCD.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblIND_BCD.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblIND_BCD.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblIND_BCD.Location = new System.Drawing.Point(171, 495);
            this.lblIND_BCD.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblIND_BCD.MoveControl = null;
            this.lblIND_BCD.Name = "lblIND_BCD";
            this.lblIND_BCD.Size = new System.Drawing.Size(460, 50);
            this.lblIND_BCD.TabIndex = 207;
            this.lblIND_BCD.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblIND_BCD.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(639, 437);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(615, 50);
            this.label9.TabIndex = 203;
            this.label9.Text = "총 생산량";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Gray;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(15, 437);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(150, 50);
            this.label13.TabIndex = 201;
            this.label13.Text = "실적일자";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.Black;
            this.label8.Location = new System.Drawing.Point(15, 381);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(1240, 50);
            this.label8.TabIndex = 143;
            this.label8.Text = "실적정보";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.Black;
            this.label7.Location = new System.Drawing.Point(15, 13);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(1240, 50);
            this.label7.TabIndex = 142;
            this.label7.Text = "작업지시정보";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // POP_WRK18
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK18";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK18_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label14;
        private MESLabel lblPRFM_BOX;
        private System.Windows.Forms.Label label12;
        private MESLabel lblPRFM_PLT;
        private System.Windows.Forms.Label label10;
        private MESLabel lblIND_BCD;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label13;
        private System.Windows.Forms.Label label11;
        private MESLabel lblTOT_EA;
        private System.Windows.Forms.Label label15;
        private MESLabel lblTOT_BAG;
        private System.Windows.Forms.Label label16;
        private MESLabel lblTOT_BOX;
        private System.Windows.Forms.Label label23;
        private MESLabel lblTOT_PLT;
        private System.Windows.Forms.Label label24;
        private MESLabel lblLOT_NO;
        private System.Windows.Forms.Label label22;
        private MESLabel lblPRFM_EA;
        private System.Windows.Forms.Label label17;
        private MESLabel lblPRFM_BAG;
        private System.Windows.Forms.Label label1;
        private MESLabel lblEA_QTY;
        private System.Windows.Forms.Label label2;
        private MESLabel lblBAG_QTY;
        private System.Windows.Forms.Label label3;
        private MESLabel lblBOX_QTY;
        private System.Windows.Forms.Label label4;
        private MESLabel lblPLT_QTY;
        private System.Windows.Forms.Label label6;
        private MESLabel lblWRK_ORDR_RMK;
        private System.Windows.Forms.Label label5;
        private MESLabel lblWRK_ORDR_NO;
        private System.Windows.Forms.Label label18;
        private MESLabel lblPRD_REQ_DT;
        private MESLabel lblWRK_ORDR_SEQNO;
        private System.Windows.Forms.Label label19;
        private System.Windows.Forms.Label label20;
        private MESLabel lblMATNR;
        private System.Windows.Forms.Label label21;
        private MESLabel lblSIZE;
        private MESLabel lblMATNR_SPEC;
        private MESLabel lblPRFM_DATE;
        private System.Windows.Forms.Label lblEndChkName;
        private MESLabel lblEndChk;

    }
}
