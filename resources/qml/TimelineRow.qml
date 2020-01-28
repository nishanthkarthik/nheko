import QtQuick 2.6
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

import im.nheko 1.0

import "./delegates"

RowLayout {
	property var view: chat

	anchors.leftMargin: avatarSize + 4
	anchors.left: parent.left
	anchors.right: parent.right

	//height: Math.max(model.replyTo ? reply.height + contentItem.height + 4 : contentItem.height, 16)

	Column {
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignTop
		spacing: 4

		// fancy reply, if this is a reply
		Reply {
			visible: model.replyTo
			modelData: chat.model.getDump(model.replyTo)
			userColor: chat.model.userColor(modelData.userId, colors.window)
		}

		// actual message content
		MessageDelegate {
			id: contentItem

			width: parent.width

			modelData: model
		}
	}

	StatusIndicator {
		state: model.state
		Layout.alignment: Qt.AlignRight | Qt.AlignTop
		Layout.preferredHeight: 16
	}

	EncryptionIndicator {
		visible: model.isEncrypted
		Layout.alignment: Qt.AlignRight | Qt.AlignTop
		Layout.preferredHeight: 16
	}

	ImageButton {
		Layout.alignment: Qt.AlignRight | Qt.AlignTop
		Layout.preferredHeight: 16
		id: replyButton

		image: ":/icons/icons/ui/mail-reply.png"
		ToolTip {
			visible: replyButton.hovered
			text: qsTr("Reply")
			palette: colors
		}

		onClicked: view.model.replyAction(model.id)
	}
	ImageButton {
		Layout.alignment: Qt.AlignRight | Qt.AlignTop
		Layout.preferredHeight: 16
		id: optionsButton

		image: ":/icons/icons/ui/vertical-ellipsis.png"
		ToolTip {
			visible: optionsButton.hovered
			text: qsTr("Options")
			palette: colors
		}

		onClicked: contextMenu.open()

		Menu {
			y: optionsButton.height
			id: contextMenu
			palette: colors

			MenuItem {
				text: qsTr("Read receipts")
				onTriggered: view.model.readReceiptsAction(model.id)
			}
			MenuItem {
				text: qsTr("Mark as read")
			}
			MenuItem {
				text: qsTr("View raw message")
				onTriggered: view.model.viewRawMessage(model.id)
			}
			MenuItem {
				text: qsTr("Redact message")
				onTriggered: view.model.redactEvent(model.id)
			}
			MenuItem {
				visible: model.type == MtxEvent.ImageMessage || model.type == MtxEvent.VideoMessage || model.type == MtxEvent.AudioMessage || model.type == MtxEvent.FileMessage || model.type == MtxEvent.Sticker
				text: qsTr("Save as")
				onTriggered: timelineManager.timeline.saveMedia(model.id)
			}
		}
	}

	Text {
		Layout.alignment: Qt.AlignRight | Qt.AlignTop
		text: model.timestamp.toLocaleTimeString("HH:mm")
		color: inactiveColors.text

		MouseArea{
			id: ma
			anchors.fill: parent
			hoverEnabled: true
		}

		ToolTip {
			visible: ma.containsMouse
			text: Qt.formatDateTime(model.timestamp, Qt.DefaultLocaleLongDate)
			palette: colors
		}
	}
}
