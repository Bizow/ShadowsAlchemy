// Auto-generated
let project = new Project('ShadowsAlchemy_1_0_0');

project.addSources('Sources');
project.addLibrary("D:/Blender/armsdk/armory");
project.addLibrary("D:/Blender/armsdk/iron");
project.addParameter('armory.trait.internal.UniformsManager');
project.addParameter("--macro keep('armory.trait.internal.UniformsManager')");
project.addParameter('arm.Html');
project.addParameter("--macro keep('arm.Html')");
project.addShaders("build_ShadowsAlchemy/compiled/Shaders/*.glsl", { noembed: false});
project.addAssets("build_ShadowsAlchemy/compiled/Assets/**", { notinlist: true });
project.addAssets("build_ShadowsAlchemy/compiled/Shaders/*.arm", { notinlist: true });
project.addAssets("D:/Blender/Drone/textures/ImphenziaPixPal_Attributes.png", { notinlist: true });
project.addAssets("D:/Blender/Drone/textures/ImphenziaPixPal_BaseColor.png", { notinlist: true });
project.addAssets("D:/Blender/Drone/textures/ImphenziaPixPal_Emission.png", { notinlist: true });
project.addAssets("D:/Blender/armsdk/armory/Assets/brdf.png", { notinlist: true });
project.addAssets("D:/Blender/armsdk/armory/Assets/smaa_area.png", { notinlist: true });
project.addAssets("D:/Blender/armsdk/armory/Assets/smaa_search.png", { notinlist: true });
project.addParameter('--debug');
project.addLibrary("D:/Blender/armsdk/lib/zui");
project.addAssets("D:/Blender/armsdk/armory/Assets/font_default.ttf", { notinlist: false });
project.addDefine('arm_deferred');
project.addDefine('arm_csm');
project.addDefine('rp_hdr');
project.addDefine('rp_renderer=Deferred');
project.addDefine('rp_shadowmap');
project.addDefine('rp_shadowmap_cascade=1024');
project.addDefine('rp_shadowmap_cube=512');
project.addDefine('rp_background=World');
project.addDefine('rp_render_to_texture');
project.addDefine('rp_compositornodes');
project.addDefine('rp_antialiasing=SMAA');
project.addDefine('rp_supersampling=1');
project.addDefine('rp_ssgi=SSAO');
project.addDefine('rp_gbuffer_emission');
project.addDefine('arm_assert_level=Warning');
project.addDefine('arm_soundcompress');
project.addDefine('arm_audio');
project.addDefine('arm_ui');
project.addDefine('arm_skin');
project.addDefine('arm_morph_target');
project.addDefine('arm_particles');
project.addDefine('arm_resizable');
project.addDefine('armory');


resolve(project);
