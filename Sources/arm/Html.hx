package arm;

class Html extends iron.Trait {
	var css = "#khanvas {
		display: block;
		outline: none;
		border: none !important;
		bottom: 0 !important;
		height: 100vh !important;
		left: 0 !important;
		min-height: 100% !important;
		min-width: 100% !important;
		position: fixed !important;
		right: 0 !important;
		top: 0 !important;
		width: 100% !important;
	}";

	public function new() {
		super();

		notifyOnInit(function() {
			#if kha_krom
			#else
			js.Syntax.code('var style = document.createElement("style"); style.type = "text/css"; style.appendChild(document.createTextNode({0})); document.getElementsByTagName("head")[0].appendChild(style);',
				css);
			#end
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
}
/*
	<style>
		html,
		body,
		canvas,
		div {
			margin: 0;
			padding: 0;
			width: 100%;
			height: 100%;
		}

		p {
			margin: 0;
			padding: 0;
			width: 100%;
			height: 100%;
		}

		#khanvas {
			display: block;
			outline: none;
			border: none !important;
			bottom: 0 !important;
			height: 100vh !important;
			left: 0 !important;
			min-height: 100% !important;
			min-width: 100% !important;
			position: fixed !important;
			right: 0 !important;
			top: 0 !important;
			width: 100% !important;
		}
	</style>
 */
